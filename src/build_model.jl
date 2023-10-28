function build_model!(prb::Problem)
    preprocess!(prb)
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
    $RTC => build_real_time_commit!
    $DAB => build_day_ahead_bid!
    $DAC => build_day_ahead_commit!
end

function build_subproblem!(sp::Model, idx::Int, prb::Problem)
    problem_info = prb.cache.problem_type[idx]
    constructor! = switch(problem_info.problem_type)
    constructor!(sp, prb, problem_info)
    return nothing
end

function build_real_time_bid!(sp::Model, prb::Problem, problem_info::ProblemInfo)
    #add variables
    variable_volume!(sp, prb)
    variable_inflow!(sp, prb)
    variable_real_time_bid!(sp, prb)
    variable_day_ahead_commit!(sp, prb)
    variable_day_ahead_bid!(sp, prb)

    #add constraints
    constraint_add_inflow!(sp, prb)
    constraint_real_time_bid_bound!(sp, prb)
    constraint_copy_day_ahead_commit!(sp, prb)
    constraint_inflow!(sp, prb, problem_info.t)
    constraint_copy_day_ahead_bid!(sp, prb)

    #add objective
    set_bid_objective!(sp)
    return nothing
end

function build_real_time_commit!(sp::Model, prb::Problem, problem_info::ProblemInfo)
    #add variables
    variable_volume!(sp, prb)
    variable_generation!(sp, prb)
    variable_real_time_bid!(sp, prb)
    variable_day_ahead_commit!(sp, prb)
    variable_day_ahead_bid!(sp, prb)

    #add constraints
    constraint_add_generation!(sp, prb)
    constraint_real_time_accepted!(sp, prb, problem_info.k, problem_info.t)
    constraint_shift_day_ahead_commit!(sp, prb)
    constraint_copy_day_ahead_bid!(sp, prb)

    #add objective
    set_real_time_commit_objective!(sp, prb, problem_info.t, problem_info.k)
    return nothing
end

function build_day_ahead_bid!(sp, prb::Problem, _::ProblemInfo)
    #add variables
    variable_volume!(sp, prb)
    variable_day_ahead_bid!(sp, prb)
    variable_day_ahead_commit!(sp, prb)
    variable_real_time_bid!(sp, prb)

    #add constraints
    constraint_copy_volume!(sp, prb)
    constraint_copy_day_ahead_commit!(sp, prb)

    #add objective
    set_bid_objective!(sp)
    return nothing
end

function build_day_ahead_commit!(sp::Model, prb::Problem, problem_info::ProblemInfo)
    #add variables
    variable_volume!(sp, prb)
    variable_day_ahead_bid!(sp, prb)
    variable_day_ahead_commit!(sp, prb)
    variable_real_time_bid!(sp, prb)

    #add constraints
    constraint_copy_volume!(sp, prb)
    constraint_add_day_ahead_commit!(sp, prb, problem_info.k, problem_info.t)

    #add objective
    set_day_ahead_commit_objective!(sp, prb, problem_info.t, problem_info.k)
    return nothing
end
