function variable_volume!(sp, prb::Problem)
    @variable(
        sp,
        prb.data.V_min[i] <= volume[i=1:prb.numbers.I] <= prb.data.V_max[i],
        SDDP.State,
        initial_value = prb.data.V_0[i]
    )
    return nothing
end

function variable_real_time_bid!(sp, prb::Problem)
    @variable(
        sp,
        0.0 <= real_time_bid[1:prb.numbers.Kᵦ, 1:prb.numbers.I],
        SDDP.State,
        initial_value = 0.0
    )
    return nothing
end

function variable_day_ahead_bid!(sp, prb::Problem)
    @variable(
        sp,
        0.0 <= day_ahead_bid[1:prb.numbers.Kᵦ, 1:prb.numbers.I, 1:prb.numbers.N],
        SDDP.State,
        initial_value = 0.0
    )
    return nothing
end

function variable_inflow!(sp, prb::Problem)
    @variable(sp, inflow[1:prb.numbers.I])
    return nothing
end

function variable_generation!(sp, prb::Problem)
    @variable(sp, prb.data.V_min[i] <= generation[i=1:prb.numbers.I] <= prb.data.V_max[i])
    return nothing
end