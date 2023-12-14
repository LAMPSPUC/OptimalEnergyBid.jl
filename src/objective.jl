"""Creates an empty objective"""
function _create_objective_expression!(sp::Model)::Nothing
    @expression(sp, objective, AffExpr(0.0))
    return nothing
end

"""Sets the objective"""
function _set_objective_expression!(sp::Model)::Nothing
    @stageobjective(sp, sp[:objective])
    return nothing
end

"""Add real time clear objective function using control generation"""
function _add_real_time_clear_objective!(
    sp::Model, prb::Problem, t::Int, markov_state::Int
)::Nothing
    add_to_expression!(
        sp[:objective],
        sum(
            prb.random.prices_real_time[t][i][markov_state] *
            (sp[:generation][i] - sp[:day_ahead_clear][i, 1].in) for
            i in 1:(prb.numbers.units)
        ),
    )
    return nothing
end

"""Add real time clear objective function using state generation"""
function _add_real_time_clear_objective_state!(
    sp::Model, prb::Problem, t::Int, markov_state::Int
)::Nothing
    add_to_expression!(
        sp[:objective],
        sum(
            prb.random.prices_real_time[t][i][markov_state] *
            (sp[:generation][i].out - sp[:day_ahead_clear][i, 1].in) for
            i in 1:(prb.numbers.units)
        ),
    )
    return nothing
end

"""Add day ahead clear objective function"""
function _add_day_ahead_clear_objective!(
    sp::Model, prb::Problem, t::Int, markov_state::Int
)::Nothing
    temp = div(t - 1, prb.numbers.periods_per_day) + 1

    if temp != prb.numbers.days
        add_to_expression!(
            sp[:objective],
            sum(
                prb.random.prices_day_ahead[temp][n][i][markov_state] * (
                    sp[:day_ahead_clear][
                        i,
                        n + prb.numbers.periods_per_day - prb.numbers.period_of_day_ahead_clear,
                    ].out
                ) for i in 1:(prb.numbers.units), n in 1:(prb.numbers.periods_per_day)
            ),
        )
    end
    return nothing
end

"""Add ramp down penalty objective function"""
function _add_ramp_down_objective!(sp::Model, prb::Problem)::Nothing
    add_to_expression!(
        sp[:objective], -prb.options.penalty_ramp_down * sum(sp[:ramp_down_violation])
    )
    return nothing
end
