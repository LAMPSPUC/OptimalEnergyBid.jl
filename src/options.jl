function set_optimizer!(prb::Problem, optimizer::DataType)
    prb.options.optimizer = optimizer
    return nothing
end

function set_use_ramp_up!(prb::Problem, use_ramp_up::Bool)
    prb.options.use_ramp_up = use_ramp_up
    return nothing
end

function set_use_ramp_down!(prb::Problem, use_ramp_down::Bool)
    prb.options.use_ramp_down = use_ramp_down
    return nothing
end

function set_penalty_ramp_up!(prb::Problem, penalty_ramp_up::Float64)
    prb.options.penalty_ramp_up = penalty_ramp_up
    return nothing
end

function set_penalty_ramp_down!(prb::Problem, set_penalty_ramp_down!::Float64)
    prb.options.set_penalty_ramp_down! = set_penalty_ramp_down!
    return nothing
end

function evaluate_flags!(prb::Problem)
    prb.flags.generation_as_state = prb.options.use_ramp_up || prb.options.use_ramp_down
    return nothing
end