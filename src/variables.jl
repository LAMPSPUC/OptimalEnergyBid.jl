function variable_volume!(sp::Model, prb::Problem)
    @variable(
        sp,
        prb.data.volume_min[i] <= volume[i=1:(prb.numbers.I)] <= prb.data.volume_max[i],
        SDDP.State,
        initial_value = prb.data.volume_initial[i]
    )
    return nothing
end

function variable_real_time_bid!(sp::Model, prb::Problem)
    @variable(
        sp,
        0.0 <= real_time_bid[1:(prb.numbers.Kᵦ), 1:(prb.numbers.I)],
        SDDP.State,
        initial_value = 0.0
    )
    return nothing
end

function variable_day_ahead_bid!(sp::Model, prb::Problem)
    @variable(
        sp,
        0.0 <= day_ahead_bid[1:(prb.numbers.Kᵧ), 1:(prb.numbers.I), 1:(prb.numbers.N)],
        SDDP.State,
        initial_value = 0.0
    )
    return nothing
end

function variable_day_ahead_clear!(sp::Model, prb::Problem)
    @variable(
        sp,
        0.0 <=
            day_ahead_clear[1:(prb.numbers.I), 1:(2 * prb.numbers.N - prb.numbers.V + 1)],
        SDDP.State,
        initial_value = 0.0
    )
    return nothing
end

function variable_generation_state!(sp::Model, prb::Problem)
    @variable(sp, prb.data.volume_min[i] <= generation[i=1:(prb.numbers.I)] <= prb.data.volume_max[i],
    SDDP.State, initial_value = prb.data.generation_initial[i])
    return nothing
end

function variable_inflow!(sp::Model, prb::Problem)
    @variable(sp, inflow[1:(prb.numbers.I)])
    return nothing
end

function variable_generation!(sp::Model, prb::Problem)
    @variable(sp, prb.data.volume_min[i] <= generation[i=1:(prb.numbers.I)] <= prb.data.volume_max[i])
    return nothing
end

function variable_spillage!(sp::Model, prb::Problem)
    @variable(sp, 0.0 <= spillage[i=1:(prb.numbers.I)])
    return nothing
end

function variable_ramp_up_violation!(sp::Model, prb::Problem)
    @variable(sp, 0.0 <= ramp_up_violation[i=1:(prb.numbers.I)])
    return nothing
end

function variable_ramp_down_violation!(sp::Model, prb::Problem)
    @variable(sp, 0.0 <= ramp_down_violation[i=1:(prb.numbers.I)])
    return nothing
end
