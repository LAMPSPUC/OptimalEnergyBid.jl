function build_model!(prb::Problem)
    preprocess!(prb)
    evaluate_flags!(prb)
    graph = build_graph(prb)

    prb.model = SDDP.PolicyGraph(
        graph;
        sense=:Max,
        optimizer=prb.options.optimizer,
        upper_bound=100.0,
        direct_mode=false,
    ) do sp, idx
        build_subproblem!(sp, idx, prb)
    end
    return nothing
end

switch(type::ProblemType) = @match type begin
    $RTB => build_real_time_bid!
    $RTC => build_real_time_clear!
    $DAB => build_day_ahead_bid!
    $DAC => build_day_ahead_clear!
end

function build_subproblem!(sp::Model, idx::Int, prb::Problem)
    problem_info = prb.cache.problem_info[idx]
    constructor! = switch(problem_info.problem_type)
    constructor!(sp, prb, problem_info)
    return nothing
end

function build_real_time_bid!(sp::Model, prb::Problem, problem_info::ProblemInfo)
    #add variables
    variable_volume!(sp, prb)
    variable_inflow!(sp, prb)
    variable_real_time_bid!(sp, prb)
    variable_day_ahead_clear!(sp, prb)
    variable_day_ahead_bid!(sp, prb)
    variable_spillage!(sp, prb)
    if prb.flags.generation_as_state
        variable_generation_state!(sp, prb)
    end

    #add constraints
    constraint_add_inflow!(sp, prb)
    constraint_real_time_bid_bound!(sp, prb)
    constraint_copy_day_ahead_clear!(sp, prb)
    constraint_inflow!(sp, prb, problem_info.t)
    constraint_copy_day_ahead_bid!(sp, prb)
    if prb.flags.generation_as_state
        constraint_copy_generation!(sp, prb)
    end

    #add objective
    set_bid_objective!(sp)
    return nothing
end

function build_real_time_clear!(sp::Model, prb::Problem, problem_info::ProblemInfo)
    #add variables
    variable_volume!(sp, prb)
    variable_real_time_bid!(sp, prb)
    variable_day_ahead_clear!(sp, prb)
    variable_day_ahead_bid!(sp, prb)
    if prb.flags.generation_as_state
        variable_generation_state!(sp, prb)
    else
        variable_generation!(sp, prb)
    end
    if prb.options.use_ramp_up
        variable_ramp_up_violation!(sp, prb)
    end
    if prb.options.use_ramp_down
        variable_ramp_down_violation!(sp, prb)
    end

    #add constraints
    constraint_shift_day_ahead_clear!(sp, prb)
    constraint_copy_day_ahead_bid!(sp, prb)
    if prb.flags.generation_as_state
        constraint_add_generation_state!(sp, prb)
        constraint_real_time_accepted_state!(sp, prb, problem_info.k, problem_info.t)
    else
        constraint_add_generation!(sp, prb)
        constraint_real_time_accepted!(sp, prb, problem_info.k, problem_info.t)
    end
    if prb.options.use_ramp_up
        constraint_generation_ramp_up!(sp, prb)
    end
    if prb.options.use_ramp_down
        constraint_generation_ramp_down!(sp, prb)
    end


    #add objective
    if prb.flags.generation_as_state
        set_real_time_clear_objective_state!(sp, prb, problem_info.t, problem_info.k)
    else
        set_real_time_clear_objective!(sp, prb, problem_info.t, problem_info.k)
    end
    if prb.options.use_ramp_up
        add_ramp_up_objective!(sp, prb)
    end
    if prb.options.use_ramp_down
        add_ramp_up_objective!(sp, prb)
    end
    return nothing
end

function build_day_ahead_bid!(sp, prb::Problem, _::ProblemInfo)
    #add variables
    variable_volume!(sp, prb)
    variable_day_ahead_bid!(sp, prb)
    variable_day_ahead_clear!(sp, prb)
    variable_real_time_bid!(sp, prb)
    if prb.flags.generation_as_state
        variable_generation_state!(sp, prb)
    end

    #add constraints
    constraint_copy_volume!(sp, prb)
    constraint_copy_day_ahead_clear!(sp, prb)
    if prb.flags.generation_as_state
        constraint_copy_generation!(sp, prb)
    end

    #add objective
    set_bid_objective!(sp)
    return nothing
end

function build_day_ahead_clear!(sp::Model, prb::Problem, problem_info::ProblemInfo)
    #add variables
    variable_volume!(sp, prb)
    variable_day_ahead_bid!(sp, prb)
    variable_day_ahead_clear!(sp, prb)
    variable_real_time_bid!(sp, prb)
    if prb.flags.generation_as_state
        variable_generation_state!(sp, prb)
    end

    #add constraints
    constraint_copy_volume!(sp, prb)
    constraint_add_day_ahead_clear!(sp, prb, problem_info.k, problem_info.t)
    if prb.flags.generation_as_state
        constraint_copy_generation!(sp, prb)
    end

    #add objective
    set_day_ahead_clear_objective!(sp, prb, problem_info.t, problem_info.k)
    return nothing
end
