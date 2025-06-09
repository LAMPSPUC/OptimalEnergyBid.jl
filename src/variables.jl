"""List of all variables"""
variable_list = [
    :volume,
    :real_time_bid,
    :day_ahead_bid,
    :day_ahead_clear,
    :inflow,
    :generation,
    :spillage,
    :ramp_down_violation,
]

"""Creates the volume as a state variable"""
function _variable_volume!(sp::Model, prb::Problem)::Nothing
    @variable(
        sp,
        prb.data.volume_min[i] <= volume[i=1:(prb.numbers.units)] <= prb.data.volume_max[i],
        SDDP.State,
        initial_value = prb.data.volume_initial[i]
    )
    return nothing
end

"""Creates the real time offer as a state variable"""
function _variable_real_time_bid!(sp::Model, prb::Problem)::Nothing
    @variable(
        sp,
        0.0 <= real_time_bid[1:(prb.numbers.real_time_steps), 1:(prb.numbers.units)],
        SDDP.State,
        initial_value = 0.0
    )
    return nothing
end

"""Creates the day ahead offer as a state variable"""
function _variable_day_ahead_bid!(sp::Model, prb::Problem)::Nothing
    @variable(
        sp,
        0.0 <= day_ahead_bid[
            1:(prb.numbers.day_ahead_steps),
            1:(prb.numbers.units),
            1:(prb.numbers.periods_per_day),
        ],
        SDDP.State,
        initial_value = 0.0
    )
    return nothing
end

"""Creates the day ahead clear as a state variable"""
function _variable_day_ahead_clear!(sp::Model, prb::Problem)::Nothing
    @variable(
        sp,
        0.0 <= day_ahead_clear[
            1:(prb.numbers.units),
            1:(2 * prb.numbers.periods_per_day - prb.numbers.period_of_day_ahead_clear),
        ],
        SDDP.State,
        initial_value = 0.0
    )
    return nothing
end

"""Creates the generation as a state variable"""
function _variable_generation_state!(sp::Model, prb::Problem)::Nothing
    @variable(
        sp,
        0 <= generation[i=1:(prb.numbers.units)],
        SDDP.State,
        initial_value = prb.data.generation_initial[i]
    )
    return nothing
end

"""Creates the inflow as a random variable"""
function _variable_inflow!(sp::Model, prb::Problem)::Nothing
    @variable(sp, inflow[1:(prb.numbers.units)])
    return nothing
end

"""Creates the generation as a control variable"""
function _variable_generation!(sp::Model, prb::Problem)::Nothing
    @variable(sp, 0 <= generation[i=1:(prb.numbers.units)])
    return nothing
end

"""Creates the spillage as a control variable"""
function _variable_spillage!(sp::Model, prb::Problem)::Nothing
    @variable(sp, 0.0 <= spillage[i=1:(prb.numbers.units)])
    return nothing
end

"""Creates the ramp down violation as a control variable"""
function _variable_ramp_down_violation!(sp::Model, prb::Problem)::Nothing
    @variable(sp, 0.0 <= ramp_down_violation[i=1:(prb.numbers.units)])
    return nothing
end