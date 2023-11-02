"""Build the model"""
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

"""Find the good constructor"""
switch(type::ProblemType) = @match type begin
    $RTB => build_real_time_bid!
    $RTC => build_real_time_clear!
    $DAB => build_day_ahead_bid!
    $DAC => build_day_ahead_clear!
end

"""Creates the subproblem"""
function build_subproblem!(sp::Model, idx::Int, prb::Problem)
    problem_info = prb.cache.problem_info[idx]
    constructor! = switch(problem_info.problem_type)
    constructor!(sp, prb, problem_info)
    return nothing
end

"""Creates the real time offer subproblem"""
function build_real_time_bid!(sp::Model, prb::Problem, problem_info::ProblemInfo)

    variable_volume!(sp, prb)
    variable_inflow!(sp, prb)
    variable_real_time_bid!(sp, prb)
    variable_day_ahead_clear!(sp, prb)
    variable_day_ahead_bid!(sp, prb)
    variable_spillage!(sp, prb)
    if prb.flags.generation_as_state
        variable_generation_state!(sp, prb)
        constraint_copy_generation!(sp, prb)
    end

    constraint_add_inflow!(sp, prb)
    constraint_real_time_bid_bound!(sp, prb)
    constraint_copy_day_ahead_clear!(sp, prb)
    constraint_inflow!(sp, prb, problem_info.t)
    constraint_copy_day_ahead_bid!(sp, prb)

    create_objective_expression!(sp)
    set_objective_expression!(sp)
    
    return nothing
end

"""Creates the real time clear subproblem"""
function build_real_time_clear!(sp::Model, prb::Problem, problem_info::ProblemInfo)

    variable_volume!(sp, prb)
    variable_real_time_bid!(sp, prb)
    variable_day_ahead_clear!(sp, prb)
    variable_day_ahead_bid!(sp, prb)

    create_objective_expression!(sp)

    if prb.flags.generation_as_state
        variable_generation_state!(sp, prb)
        constraint_add_generation_state!(sp, prb)
        constraint_real_time_accepted_state!(sp, prb, problem_info.k, problem_info.t)
        add_real_time_clear_objective_state!(sp, prb, problem_info.t, problem_info.k)
    else
        variable_generation!(sp, prb)
        constraint_add_generation!(sp, prb)
        constraint_real_time_accepted!(sp, prb, problem_info.k, problem_info.t)
        add_real_time_clear_objective!(sp, prb, problem_info.t, problem_info.k)
    end

    if prb.options.use_ramp_up
        variable_ramp_up_violation!(sp, prb)
        constraint_generation_ramp_up!(sp, prb)
        add_ramp_up_objective!(sp, prb)
    end

    if prb.options.use_ramp_down
        variable_ramp_down_violation!(sp, prb)
        constraint_generation_ramp_down!(sp, prb)
        add_ramp_down_objective!(sp, prb)
    end

    constraint_shift_day_ahead_clear!(sp, prb)
    constraint_copy_day_ahead_bid!(sp, prb)

    set_objective_expression!(sp)

    return nothing
end

"""Creates the day ahead offer subproblem"""
function build_day_ahead_bid!(sp, prb::Problem, _::ProblemInfo)

    variable_volume!(sp, prb)
    variable_day_ahead_bid!(sp, prb)
    variable_day_ahead_clear!(sp, prb)
    variable_real_time_bid!(sp, prb)
    if prb.flags.generation_as_state
        variable_generation_state!(sp, prb)
        constraint_copy_generation!(sp, prb)
    end

    constraint_copy_volume!(sp, prb)
    constraint_copy_day_ahead_clear!(sp, prb)

    create_objective_expression!(sp)
    set_objective_expression!(sp)
    return nothing
end

"""Creates the day ahead clear subproblem"""
function build_day_ahead_clear!(sp::Model, prb::Problem, problem_info::ProblemInfo)

    variable_volume!(sp, prb)
    variable_day_ahead_bid!(sp, prb)
    variable_day_ahead_clear!(sp, prb)
    variable_real_time_bid!(sp, prb)

    if prb.flags.generation_as_state
        variable_generation_state!(sp, prb)
        constraint_copy_generation!(sp, prb)
    end

    constraint_copy_volume!(sp, prb)
    constraint_add_day_ahead_clear!(sp, prb, problem_info.k, problem_info.t)

    create_objective_expression!(sp)
    add_day_ahead_clear_objective!(sp, prb, problem_info.t, problem_info.k)
    set_objective_expression!(sp)
    return nothing
end
