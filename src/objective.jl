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

function set_day_ahead_clear_objective!(sp::Model, prb::Problem, t::Int, k::Int)
    temp = div(t - 1, prb.numbers.N) + 1
    @stageobjective(
        sp,
        sum(
            prb.random_variables.πᵧ[k, i, n, temp] *
            (sp[:day_ahead_clear][i, n + prb.numbers.N - prb.numbers.V + 1].out) for
            i in 1:(prb.numbers.I), n in 1:(prb.numbers.N)
        )
    )
    return nothing
end
