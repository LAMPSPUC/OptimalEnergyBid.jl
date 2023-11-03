"""Creates an empty objective"""
function _create_objective_expression!(sp::Model)
    @expression(sp, objective, AffExpr(0.0))
    return nothing
end

"""Sets the objective"""
function _set_objective_expression!(sp::Model)
    @stageobjective(sp, sp[:objective])
    return nothing
end

"""Add real time clear objective function using control generation"""
function _add_real_time_clear_objective!(sp::Model, prb::Problem, t::Int, k::Int)
    add_to_expression!(
        sp[:objective],
        sum(
            prb.random_variables.πᵦ[k, i, t] *
            (sp[:generation][i] - sp[:day_ahead_clear][i, 1].in) for i in 1:(prb.numbers.I)
        ),
    )
    return nothing
end

"""Add real time clear objective function using state generation"""
function _add_real_time_clear_objective_state!(sp::Model, prb::Problem, t::Int, k::Int)
    add_to_expression!(
        sp[:objective],
        sum(
            prb.random_variables.πᵦ[k, i, t] *
            (sp[:generation][i].out - sp[:day_ahead_clear][i, 1].in) for
            i in 1:(prb.numbers.I)
        ),
    )
    return nothing
end

"""Add day ahead clear objective function"""
function _add_day_ahead_clear_objective!(sp::Model, prb::Problem, t::Int, k::Int)
    temp = div(t - 1, prb.numbers.N) + 1

    if temp != prb.numbers.D
        add_to_expression!(
            sp[:objective],
            sum(
                prb.random_variables.πᵧ[k, i, n, temp] *
                (sp[:day_ahead_clear][i, n + prb.numbers.N - prb.numbers.V + 1].out) for
                i in 1:(prb.numbers.I), n in 1:(prb.numbers.N)
            ),
        )
    end
    return nothing
end

"""Add ramp up penalty objective function"""
function _add_ramp_up_objective!(sp::Model, prb::Problem)
    add_to_expression!(
        sp[:objective], -prb.options.penalty_ramp_up * sum(sp[:ramp_up_violation])
    )
    return nothing
end

"""Add ramp down penalty objective function"""
function _add_ramp_down_objective!(sp::Model, prb::Problem)
    add_to_expression!(
        sp[:objective], -prb.options.penalty_ramp_down * sum(sp[:ramp_down_violation])
    )
    return nothing
end
