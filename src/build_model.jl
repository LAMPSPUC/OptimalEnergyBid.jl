function build_model(prb::Problem)
    graph = build_graph(prb)

    model = SDDP.PolicyGraph(
        graph;
        sense=:Min,
        optimizer=prb.options.optimizer,
        lower_bound=0.0,
        direct_mode=false,
    ) do sp, idx
        build_subproblem!(sp, idx, prb)
    end
    return model
end

switch(type) = @match type begin
    $RTB => build_real_time_bid!
    $RTC => build_real_time_commit!
    $DAB => build_day_ahead_bid!
    $DAC => build_day_ahead_commit!
 end

function build_subproblem!(sp, idx::Int, prb::Problem)
    problem_info = prb.cache.problem_type[idx]
    constructor, t , k = switch(problem_info.problem_type)
    constructor(sp, prb, problem_info.t, problem_info.k)
end

function build_real_time_bid!(sp, prb::Problem, t::Int, k::Int)
    #add variables
    variable_volume!(sp, prb)
    variable_inflow!(sp, prb)
    variable_real_time_bid!(sp, prb)

    #add constraints
    constraint_add_inflow!(sp, prb)
    constraint_real_time_bid_bound!(sp, prb::Problem)

    #add objective
    set_bid_objective(sp)
end

function build_real_time_commit!(sp, prb::Problem, t::Int, k::Int)
    #add variables
    variable_volume!(sp, prb)
    variable_generation!(sp, prb)
    variable_real_time_bid!(sp, prb)

    #add constraints
    constraint_copy_volume!(sp, prb)
    constraint_add_generation!(sp, prb)
    constraint_real_time_accepted!(sp, prb, k)

    #add objective
end

function build_day_ahead_bid!(sp, prb::Problem, t::Int, k::Int)
    #add variables
    variable_volume!(sp, prb)

    #add constraints
    constraint_copy_volume!(sp, prb)

    #add objective
    set_bid_objective(sp)
end

function build_day_ahead_commit!(sp, prb::Problem, t::Int, k::Int)
    #add variables
    variable_volume!(sp, prb)

    #add constraints
    constraint_copy_volume!(sp, prb)

    #add objective
end