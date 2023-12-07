"""Build the model"""
function build_model!(prb::Problem)
    _preprocess!(prb)
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
