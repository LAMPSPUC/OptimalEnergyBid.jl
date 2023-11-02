"""Set the optimizer"""
function set_optimizer!(prb::Problem, optimizer::DataType)
    prb.options.optimizer = optimizer
    return nothing
end

"""Set the use of ramp up"""
function set_use_ramp_up!(prb::Problem, use_ramp_up::Bool)
    prb.options.use_ramp_up = use_ramp_up
    return nothing
end

"""Set the use of ramp down"""
function set_use_ramp_down!(prb::Problem, use_ramp_down::Bool)
    prb.options.use_ramp_down = use_ramp_down
    return nothing
end

"""Set the penalty of ramp up violation"""
function set_penalty_ramp_up!(prb::Problem, penalty_ramp_up::Float64)
    prb.options.penalty_ramp_up = penalty_ramp_up
    return nothing
end

"""Set the penalty of ramp down violation"""
function set_penalty_ramp_down!(prb::Problem, penalty_ramp_down::Float64)
    prb.options.penalty_ramp_down = penalty_ramp_down
    return nothing
end

"""Evaluate all flags"""
function evaluate_flags!(prb::Problem)
    prb.flags.generation_as_state = prb.options.use_ramp_up || prb.options.use_ramp_down
    return nothing
end