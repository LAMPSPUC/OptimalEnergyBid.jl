"""Build the model"""
function build_model!(prb::Problem, validade::Bool=false)::Nothing
    if validade
        validate_problem!(prb)
    else
        _evaluate_flags!(prb)
    end

    _preprocess!(prb)
    graph = _build_graph(prb)

    prb.model = SDDP.PolicyGraph(
        graph;
        sense=:Max,
        optimizer=prb.options.optimizer,
        upper_bound=_evaluate_upper_bound(prb),
        direct_mode=false,
    ) do sp, node
        t, markov_state = node
        _build_subproblem!(sp, prb, t, markov_state)
    end
    return nothing
end

"""Creates the SDDP graph"""
function _build_graph(prb::Problem)::SDDP.Graph
    graph = SDDP.MarkovianGraph(prb.random.markov_transitions)
    return graph
end

"""Evaluate the upper bound"""
function _evaluate_upper_bound(prb::Problem)::Float64
    numbers = prb.numbers
    random = prb.random
    data = prb.data

    temp = zeros(numbers.buses)
    for t in 1:(numbers.duration), b in 1:(numbers.buses)
        temp[b] = max(temp[b], maximum(random.prices_real_time[t][b]))
    end
    for d in 1:(numbers.days), j in 1:(numbers.periods_per_day), b in 1:(numbers.buses)
        temp[b] = max(temp[b], maximum(random.prices_day_ahead[d][j][b]))
    end
    return JuMP.LinearAlgebra.dot(temp, data.volume_max) * numbers.duration
end

"""Creates the subproblem"""
function _build_subproblem!(sp::Model, prb::Problem, t::Int, markov_state::Int)::Nothing
    numbers = prb.numbers
    options = prb.options
    flags = prb.flags

    _variable_volume!(sp, prb)
    _variable_inflow!(sp, prb)
    _variable_real_time_bid!(sp, prb)
    _variable_spillage!(sp, prb)
    _variable_day_ahead_bid!(sp, prb)
    _variable_day_ahead_clear!(sp, prb)
    _constraint_inflow!(sp, prb, t, markov_state)
    _constraint_real_time_bid_bound!(sp, prb)
    _create_objective_expression!(sp)

    if flags.generation_as_state
        _variable_generation_state!(sp, prb)
        _constraint_volume_balance_state!(sp, prb)
        _constraint_real_time_accepted_state!(sp, prb, t, markov_state)
        _add_real_time_clear_objective_state!(sp, prb, t, markov_state)
    else
        _variable_generation!(sp, prb)
        _constraint_volume_balance!(sp, prb)
        _constraint_real_time_accepted!(sp, prb, t, markov_state)
        _add_real_time_clear_objective!(sp, prb, t, markov_state)
    end

    if options.use_ramp_down
        _variable_ramp_down_violation!(sp, prb)
        _constraint_ramp_down!(sp, prb)
        _add_ramp_down_objective!(sp, prb)
    end

    if options.use_ramp_up
        _constraint_ramp_up!(sp, prb)
    end

    if options.use_day_ahead_bid_bound
        _constraint_bound_day_ahead_bid!(sp, prb)
    end

    if !_is_offer_day_ahead(numbers, t)
        _constraint_copy_day_ahead_bid!(sp, prb)
    end

    if _is_clear_day_ahead(numbers, t)
        _constraint_add_day_ahead_clear!(sp, prb, t, markov_state)
        _add_day_ahead_clear_objective!(sp, prb, t, markov_state)
    else
        _constraint_shift_day_ahead_clear!(sp, prb)
    end

    _set_objective_expression!(sp)
    return nothing
end

"""Is offer day ahead"""
function _is_offer_day_ahead(numbers::Numbers, t::Int)::Bool
    return _clever_mod(numbers, t, numbers.period_of_day_ahead_bid)
end

"""Is clear day ahead"""
function _is_clear_day_ahead(numbers::Numbers, t::Int)::Bool
    return _clever_mod(numbers, t, numbers.period_of_day_ahead_clear)
end

"""Clever mod"""
function _clever_mod(numbers::Numbers, t::Int, base::Int)::Bool
    return mod(t - base + numbers.first_period - 1, numbers.periods_per_day) == 0
end

"""Validate the problem"""
function validate_problem!(prb::Problem)::Nothing
    _evaluate_flags!(prb)
    _validate_numbers(prb)
    _validate_data(prb)
    _validate_random(prb)
    return nothing
end

"""Validate the numbers"""
function _validate_numbers(prb::Problem)::Nothing
    numbers = prb.numbers

    @assert 1 <= numbers.periods_per_day
    @assert 1 <= numbers.first_period && numbers.first_period <= numbers.periods_per_day
    @assert 1 <= numbers.units
    @assert 1 <= numbers.buses
    @assert 1 <= numbers.period_of_day_ahead_bid &&
        numbers.period_of_day_ahead_bid <= numbers.periods_per_day
    @assert 1 <= numbers.period_of_day_ahead_clear &&
        numbers.period_of_day_ahead_clear <= numbers.periods_per_day
    @assert 1 <= numbers.duration
    @assert 1 <= numbers.real_tume_steps
    @assert 1 <= numbers.day_ahead_steps

    return nothing
end

"""Validate the data"""
function _validate_data(prb::Problem)::Nothing
    numbers = prb.numbers
    options = prb.options
    flags = prb.flags
    data = prb.data

    @assert length(data.volume_max) >= numbers.units
    @assert length(data.volume_min) >= numbers.units
    @assert length(data.volume_initial) >= numbers.units
    @assert length(data.unit_to_bus) >= numbers.units

    @assert length(data.prices_real_time_curve) >= numbers.duration
    for t in 1:(numbers.duration)
        @assert length(data.prices_real_time_curve[t]) >= numbers.units
        for i in 1:(numbers.units)
            @assert length(data.prices_real_time_curve[t][i]) >= numbers.real_tume_steps
        end
    end

    @assert length(data.prices_day_ahead_curve) >= numbers.days
    for d in 1:(numbers.days)
        @assert length(data.prices_day_ahead_curve[d]) >= numbers.periods_per_day
        for j in 1:(numbers.periods_per_day)
            @assert length(data.prices_day_ahead_curve[d][j]) >= numbers.units
            for i in 1:(numbers.units)
                @assert length(data.prices_day_ahead_curve[d][j][i]) >=
                    numbers.day_ahead_steps
            end
        end
    end

    if options.use_ramp_up
        @assert length(data.ramp_up) >= numbers.units
    end

    if options.use_ramp_down
        @assert length(data.ramp_down) >= numbers.units
    end

    if flags.generation_as_state
        @assert length(data.generation_initial) >= numbers.units
    end

    @assert length(data.names) >= numbers.units

    return nothing
end

"""Validate the random"""
function _validate_random(prb::Problem)::Nothing
    numbers = prb.numbers
    random = prb.random

    @assert length(random.markov_transitions) >= numbers.duration
    temp = []
    for t in 1:(numbers.duration)
        push!(temp, size(random.markov_transitions[t])[2])
    end

    @assert length(random.prices_real_time) >= numbers.duration
    for t in 1:(numbers.duration)
        @assert length(random.prices_real_time[t]) >= numbers.buses
        for b in 1:(numbers.buses)
            @assert length(random.prices_real_time[t][b]) >= temp[t]
        end
    end

    @assert length(random.prices_day_ahead) >= numbers.days
    for d in 1:(numbers.days)
        @assert length(random.prices_day_ahead[d]) >= numbers.periods_per_day
        for j in 1:(numbers.periods_per_day)
            @assert length(random.prices_day_ahead[d][j]) >= numbers.buses
            for b in 1:(numbers.buses)
                @assert length(random.prices_day_ahead[d][j][b]) >=
                    temp[j + (numbers.periods_per_day * (d - 1))]
            end
        end
    end

    @assert length(random.inflow) >= numbers.duration
    @assert length(random.inflow_probability) >= numbers.duration
    for t in 1:(numbers.duration)
        @assert length(random.inflow[t]) >= temp[t]
        @assert length(random.inflow_probability[t]) >= temp[t]
        for z in 1:temp[t]
            L = length(random.inflow[t][z])
            @assert length(random.inflow[t][z]) == length(random.inflow_probability[t][z])
            @assert sum(random.inflow_probability[t][z]) ≈ 1
            for l in 1:L
                @assert length(random.inflow[t][z][l]) >= numbers.units
            end
        end
    end

    return nothing
end
