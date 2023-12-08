"""Build the model"""
function build_model!(prb::Problem, validade::Bool=false)
    _preprocess!(prb)
    if validade
        validate_problem(prb)
    end
    _evaluate_flags!(prb)
    graph = _build_graph(prb)

    prb.model = SDDP.PolicyGraph(
        graph;
        sense=:Max,
        optimizer=prb.options.optimizer,
        upper_bound=100.0,
        direct_mode=false,
    ) do sp, node
        t, markov_state = node
        _build_subproblem!(sp, prb, t, markov_state)
    end
    return nothing
end

"""Creates the SDDP graph"""
function _build_graph(prb::Problem)::SDDP.Graph
    graph = SDDP.MarkovianGraph(prb.random.P)
    return graph
end

"""Creates the subproblem"""
function _build_subproblem!(sp::Model, prb::Problem, t::Int, markov_state::Int)
    _variable_volume!(sp, prb)
    _variable_inflow!(sp, prb)
    _variable_real_time_bid!(sp, prb)
    _variable_spillage!(sp, prb)
    _variable_day_ahead_bid!(sp, prb)
    _variable_day_ahead_clear!(sp, prb)
    _constraint_inflow!(sp, prb, t, markov_state)
    _constraint_shift_day_ahead_clear!(sp, prb)
    _constraint_real_time_bid_bound!(sp, prb)
    _create_objective_expression!(sp)

    if prb.flags.generation_as_state
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

    if prb.options.use_ramp_down
        _variable_ramp_down_violation!(sp, prb)
        _constraint_ramp_down!(sp, prb)
        _add_ramp_down_objective!(sp, prb)
    end

    if prb.options.use_ramp_up
        _constraint_ramp_up!(sp, prb)
    end

    if prb.options.use_day_ahead_bid_bound
        _constraint_bound_day_ahead_bid!(sp, prb)
    end

    if mod(t - prb.numbers.U + prb.numbers.n₀ - 1, prb.numbers.N) != 0
        _constraint_copy_day_ahead_bid!(sp, prb)
    end

    if mod(t - prb.numbers.V + prb.numbers.n₀ - 1, prb.numbers.N) == 0
        _constraint_add_day_ahead_clear!(sp, prb, t, markov_state)
        _add_day_ahead_clear_objective!(sp, prb, t, markov_state)
    end

    _set_objective_expression!(sp)
    return nothing
end

"""Validate the problem"""
function validate_problem(prb::Problem)
    _validate_numbers(prb)
    _validate_data(prb)
    _validate_random(prb)
    return nothing
end

"""Validate the numbers"""
function _validate_numbers(prb::Problem)
    numbers = prb.numbers

    @assert 1 <= numbers.N
    @assert 1 <= numbers.n₀ && numbers.n₀ <= numbers.N
    @assert 1 <= numbers.I
    @assert 1 <= numbers.U && numbers.U <= numbers.N
    @assert 1 <= numbers.V && numbers.V <= numbers.N
    @assert 1 <= numbers.T
    @assert 1 <= numbers.Kᵦ
    @assert 1 <= numbers.Kᵧ

    return nothing
end

"""Validate the data"""
function _validate_data(prb::Problem)
    numbers = prb.numbers
    options = prb.options
    flags = prb.flags
    data = prb.data

    @assert length(data.volume_max) >= numbers.I
    @assert length(data.volume_min) >= numbers.I
    @assert length(data.volume_initial) >= numbers.I

    @assert length(data.pᵦ) >= numbers.T
    for t in 1:(numbers.T)
        @assert length(data.pᵦ[t]) >= numbers.I
        for i in 1:(numbers.I)
            @assert length(data.pᵦ[t][i]) >= numbers.Kᵦ
        end
    end

    @assert length(data.pᵧ) >= numbers.D
    for d in 1:(numbers.D)
        @assert length(data.pᵧ[d]) >= numbers.N
        for j in 1:(numbers.N)
            @assert length(data.pᵧ[d][j]) >= numbers.I
            for i in 1:(numbers.I)
                @assert length(data.pᵧ[d][j][i]) >= numbers.Kᵧ
            end
        end
    end

    if options.use_ramp_up
        @assert length(data.ramp_up) >= numbers.I
    end

    if options.use_ramp_down
        @assert length(data.ramp_down) >= numbers.I
    end

    if flags.generation_as_state
        @assert length(data.generation_initial) >= numbers.I
    end

    return nothing
end

"""Validate the random"""
function _validate_random(prb::Problem)
    numbers = prb.numbers
    random = prb.random

    @assert length(random.P) >= numbers.T
    temp = []
    for t in 1:(numbers.T)
        push!(temp, size(random.P[t])[2])
    end

    @assert length(random.πᵦ) >= numbers.T
    for t in 1:(numbers.T)
        @assert length(random.πᵦ[t]) >= numbers.I
        for i in 1:(numbers.I)
            @assert length(random.πᵦ[t][i]) >= temp[t]
        end
    end

    @assert length(random.πᵧ) >= numbers.D
    for d in 1:(numbers.D)
        @assert length(random.πᵧ[d]) >= numbers.N
        for j in 1:(numbers.N)
            @assert length(random.πᵧ[d][j]) >= numbers.I
            for i in 1:(numbers.I)
                @assert length(random.πᵧ[d][j][i]) >= temp[j + (numbers.N * (d - 1))]
            end
        end
    end

    @assert length(random.πᵪ) >= numbers.T
    @assert length(random.ωᵪ) >= numbers.T
    for t in 1:(numbers.T)
        @assert length(random.πᵪ[t]) >= temp[t]
        @assert length(random.ωᵪ[t]) >= temp[t]
        for z in 1:temp[t]
            L = length(random.πᵪ[t][z])
            @assert length(random.πᵪ[t][z]) == length(random.ωᵪ[t][z])
            @assert sum(random.ωᵪ[t][z]) ≈ 1
            for l in 1:L
                @assert length(random.πᵪ[t][z][l]) >= numbers.I
            end
        end
    end

    return nothing
end
