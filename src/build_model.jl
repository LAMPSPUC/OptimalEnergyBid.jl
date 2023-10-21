function build_model(prb::Problem)
    graph = build_graph(prb)

    model = SDDP.PolicyGraph(
        graph;
        sense=:Min,
        optimizer=prb.options.optimizer,
        lower_bound=0.0,
        direct_mode=false,
    ) do sp, t
        build_subproblem!(sp, t, prb)
    end
    return model
end

switch(type) = @match type begin
    $RTB => build_real_time_bid!
    $RTC => build_real_time_commit!
    $DAB => build_day_ahead_bid!
    $DAC => build_day_ahead_commit!
 end

function build_subproblem!(sp, t::Int, prb::Problem)
    type = prb.cache.problem_type[t]
    constructor = switch(type)
    constructor(sp, t, prb)
end

function build_real_time_bid!(sp, t::Int, prb::Problem)
    #add variables
    variable_volume!(sp, prb)
    variable_inflow!(sp, prb)
    variable_real_time_bid!(sp, prb)

    #add constraints
    constraint_add_inflow!(sp, prb)
    constraint_real_time_bid_bound!(sp, prb::Problem)
end

function build_real_time_commit!(sp, t::Int, prb::Problem)
    #add variables
    variable_volume!(sp, prb)
    variable_generation!(sp, prb)
    variable_real_time_bid!(sp, prb)

    #add constraints
    constraint_copy_volume!(sp, prb)
    constraint_add_generation!(sp, prb)
end

function build_day_ahead_bid!(sp, t::Int, prb::Problem)
    #add variables
    variable_volume!(sp, prb)

    #add constraints
    constraint_copy_volume!(sp, prb)
end

function build_day_ahead_commit!(sp, t::Int, prb::Problem)
    #add variables
    variable_volume!(sp, prb)

    #add constraints
    constraint_copy_volume!(sp, prb)
end