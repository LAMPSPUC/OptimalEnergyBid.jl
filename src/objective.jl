function set_bid_objective!(sp::Model)
    @stageobjective(sp, 0.0)
    return nothing
end

function set_real_time_clear_objective!(sp::Model, prb::Problem, t::Int, k::Int)
    @stageobjective(
        sp,
        sum(
            prb.random_variables.πᵦ[k, i, t] *
            (sp[:generation][i] - sp[:day_ahead_clear][i, 1].in) for i in 1:(prb.numbers.I)
        )
    )
    return nothing
end

function set_real_time_clear_objective_state!(sp::Model, prb::Problem, t::Int, k::Int)
    @stageobjective(
        sp,
        sum(
            prb.random_variables.πᵦ[k, i, t] *
            (sp[:generation][i].out - sp[:day_ahead_clear][i, 1].in) for i in 1:(prb.numbers.I)
        )
    )
    return nothing
end

function set_day_ahead_clear_objective!(sp::Model, prb::Problem, t::Int, k::Int)
    temp = div(t - 1, prb.numbers.N) + 1
    if temp != prb.numbers.D
        @stageobjective(
            sp,
            sum(
                prb.random_variables.πᵧ[k, i, n, temp] *
                (sp[:day_ahead_clear][i, n + prb.numbers.N - prb.numbers.V + 1].out) for
                i in 1:(prb.numbers.I), n in 1:(prb.numbers.N)
            )
        )
    else
        @stageobjective(sp, 0.0)
    end
    return nothing
end

function add_ramp_up_objective!(sp::Model, prb::Problem)
    @stageobjective(sp, objective_function(sp) + prb.options.penalty_ramp_up*sum(sp[:ramp_up_violation]))
    return nothing
end

function add_ramp_down_objective!(sp::Model, prb::Problem)
    @stageobjective(sp, objective_function(sp) + prb.options.penalty_ramp_down*sum(sp[:ramp_down_violation]))
    return nothing
end
