"""Parameters enum"""
@enumx Parameter begin
    Optimizer
    UseRampUp
    UseRampDown
    UseDayAheadBidBound
    PenaltyRampDown
    Lambda
    Beta
end

"""Set a parameter"""
function set_parameter!(prb::Problem, type::Parameter.T, value::Any)::Nothing
    field = Symbol(_camelcase_to_snakecase(string(type)))
    setproperty!(prb.options, field, value)
    return nothing
end

"""Evaluate all flags"""
function _evaluate_flags!(prb::Problem)::Nothing
    prb.flags.generation_as_state = prb.options.use_ramp_up || prb.options.use_ramp_down
    return nothing
end

"""Convert camelcase to snakecase"""
function _camelcase_to_snakecase(input::String)::String
    output = lowercase(input[1])
    for char in input[2:end]
        if isuppercase(char)
            output *= "_"
            output *= lowercase(char)
        else
            output *= char
        end
    end
    return output
end
