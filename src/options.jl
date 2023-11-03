"""Bool parameters enum"""
@enumx ParameterBool begin
    UseRampUp
    UseRampDown
    UseDayAheadBidBound
end

"""Set a bool parameter"""
set_bool_parameter(prb::Problem, type::ParameterBool.T, value::Bool) = @match type begin
    $(ParameterBool.UseRampUp) => _set_use_ramp_up!(prb, value)
    $(ParameterBool.UseRampDown) => _set_use_ramp_down!(prb, value)
    $(ParameterBool.UseDayAheadBidBound) => _set_day_ahead_bid_bound!(prb, value)
end

"""Float parameters enum"""
@enumx ParameterFloat begin
    PenaltyRampUp
    PenaltyRampDown
end

"""Set a float parameter"""
set_float_parameter(prb::Problem, type::ParameterFloat.T, value::Float64) = @match type begin
    $(ParameterFloat.PenaltyRampUp) => _set_penalty_ramp_up!(prb, value)
    $(ParameterFloat.PenaltyRampDown) => _set_penalty_ramp_down!(prb, value)
end

"""Set the optimizer"""
function set_optimizer!(prb::Problem, optimizer::DataType)
    prb.options.optimizer = optimizer
    return nothing
end

"""Set the use of ramp up"""
function _set_use_ramp_up!(prb::Problem, use_ramp_up::Bool)
    prb.options.use_ramp_up = use_ramp_up
    return nothing
end

"""Set the use of ramp down"""
function _set_use_ramp_down!(prb::Problem, use_ramp_down::Bool)
    prb.options.use_ramp_down = use_ramp_down
    return nothing
end

"""Set the penalty of ramp up violation"""
function _set_penalty_ramp_up!(prb::Problem, penalty_ramp_up::Float64)
    prb.options.penalty_ramp_up = penalty_ramp_up
    return nothing
end

"""Set the penalty of ramp down violation"""
function _set_penalty_ramp_down!(prb::Problem, penalty_ramp_down::Float64)
    prb.options.penalty_ramp_down = penalty_ramp_down
    return nothing
end

"""Set the use of day ahead bid bound"""
function _set_day_ahead_bid_bound!(prb::Problem, day_ahead_bid_bound::Bool)
    prb.options.day_ahead_bid_bound = day_ahead_bid_bound
    return nothing
end

"""Evaluate all flags"""
function _evaluate_flags!(prb::Problem)
    prb.flags.generation_as_state = prb.options.use_ramp_up || prb.options.use_ramp_down
    return nothing
end
