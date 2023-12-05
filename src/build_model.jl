"""Build the model"""
function build_model!(prb::Problem)
    _preprocess!(prb)
    _evaluate_flags!(prb)
    graph = _build_graph(prb)

    prb.model = SDDP.MarkovianPolicyGraph(
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
    graph = SDDP.MarkovianPolicyGraph(prb.random.P)
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

    if prb.flags.generation_as_state
        _variable_generation_state!(sp, prb)
        _constraint_add_generation_state!(sp, prb)
        _constraint_real_time_accepted_state!(sp, prb, problem_info.k, problem_info.t)
        _add_real_time_clear_objective_state!(sp, prb, problem_info.t, problem_info.k)
    else
        _variable_generation!(sp, prb)
        _constraint_add_generation!(sp, prb)
        _constraint_real_time_accepted!(sp, prb, problem_info.k, problem_info.t)
        _add_real_time_clear_objective!(sp, prb, problem_info.t, problem_info.k)
    end

    _create_objective_expression!(sp)

    _set_objective_expression!(sp)
    return nothing
end

"""Creates the real time offer subproblem"""
function _build_real_time_bid!(sp::Model, prb::Problem)
    _constraint_add_inflow!(sp, prb)
    _constraint_real_time_bid_bound!(sp, prb)
    _constraint_copy_day_ahead_clear!(sp, prb)
    _constraint_inflow!(sp, prb, problem_info.t)
    _constraint_copy_day_ahead_bid!(sp, prb)
    if prb.options.use_ramp_up
        _constraint_ramp_up_bound!(sp, prb)
    end
    return nothing
end

"""Creates the real time clear subproblem"""
function _build_real_time_clear!(sp::Model, prb::Problem)
    if prb.options.use_ramp_down
        _variable_ramp_down_violation!(sp, prb)
        _constraint_generation_ramp_down!(sp, prb)
        _add_ramp_down_objective!(sp, prb)
    end
    _constraint_shift_day_ahead_clear!(sp, prb)
    return _constraint_copy_day_ahead_bid!(sp, prb)
end

"""Creates the day ahead offer subproblem"""
function _build_day_ahead_bid!(sp, prb::Problem)
    _constraint_copy_volume!(sp, prb)
    _constraint_copy_day_ahead_clear!(sp, prb)
    if prb.options.use_day_ahead_bid_bound
        _constraint_bound_day_ahead_bid!(sp, prb)
    end
end

"""Creates the day ahead clear subproblem"""
function _build_day_ahead_clear!(sp::Model, prb::Problem)
    _constraint_copy_volume!(sp, prb)
    _constraint_add_day_ahead_clear!(sp, prb, problem_info.k, problem_info.t)
    return _add_day_ahead_clear_objective!(sp, prb, problem_info.t, problem_info.k)
end
