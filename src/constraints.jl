function constraint_inflow!(sp::Model, prb::Problem, t::Int)
    temp = [prb.random_variables.πᵪ[:, :, t][:,i] for i in 1:size(prb.random_variables.πᵪ[:, :, t],2)]
    SDDP.parameterize(
        sp, temp, prb.random_variables.ωᵪ[:, t]
    ) do ω
        return JuMP.fix.(sp[:inflow], ω)
    end
end

function constraint_copy_volume!(sp::Model, prb::Problem)
    @constraint(
        sp, copy_volume[i=1:(prb.numbers.I)], sp[:volume][i].out == sp[:volume][i].in
    )
    return nothing
end

function constraint_copy_day_ahead_bid!(sp::Model, prb::Problem)
    @constraint(
        sp,
        copy_day_ahead_bid[k=1:(prb.numbers.Kᵧ), i=1:(prb.numbers.I), n=1:(prb.numbers.N)],
        sp[:day_ahead_bid][k, i, n].out == sp[:day_ahead_bid][k, i, n].in
    )
    return nothing
end

function constraint_copy_day_ahead_clear!(sp::Model, prb::Problem)
    @constraint(
        sp,
        copy_day_ahead_clear[
            i=1:(prb.numbers.I), n=1:(2 * prb.numbers.N - prb.numbers.V + 1)
        ],
        sp[:day_ahead_clear][i, n].out == sp[:day_ahead_clear][i, n].in
    )
    return nothing
end

function constraint_shift_day_ahead_clear!(sp::Model, prb::Problem)
    @constraint(
        sp,
        shift_day_ahead_clear[
            i=1:(prb.numbers.I), n=1:(2 * prb.numbers.N - prb.numbers.V)
        ],
        sp[:day_ahead_clear][i, n].out == sp[:day_ahead_clear][i, n + 1].in
    )
    return nothing
end

function constraint_add_day_ahead_clear!(sp::Model, prb::Problem, K::Int, T::Int)
    temp = div(T - 1, prb.numbers.N) + 1
    @constraint(
        sp,
        keep_day_ahead_clear[i=1:(prb.numbers.I), n=1:(prb.numbers.N - prb.numbers.V + 1)],
        sp[:day_ahead_clear][i, n].out == sp[:day_ahead_clear][i, n].in
    )
    @constraint(
        sp,
        add_shift_day_ahead_clear[i=1:(prb.numbers.I), n=1:(prb.numbers.N)],
        sp[:day_ahead_clear][i, n + prb.numbers.N - prb.numbers.V + 1].out ==
            sum(sp[:day_ahead_bid][k, i, n].in for k in 1:prb.numbers.Kᵧ if prb.cache.acceptance_day_ahead[K,k,i,n,temp])
    )
    return nothing
end

function constraint_add_inflow!(sp::Model, prb::Problem)
    @constraint(
        sp,
        add_inflow[i=1:(prb.numbers.I)],
        sp[:volume][i].out == sp[:volume][i].in + sp[:inflow][i] - sp[:spillage][i]
    )
    return nothing
end

function constraint_real_time_bid_bound!(sp::Model, prb::Problem)
    @constraint(
        sp,
        real_time_bid_bound[i=1:(prb.numbers.I)],
        sp[:volume][i].out >= sum(sp[:real_time_bid][k, i].out for k in 1:(prb.numbers.Kᵦ))
    )
    return nothing
end

function constraint_add_generation!(sp::Model, prb::Problem)
    @constraint(
        sp,
        constraint_add_generation![i=1:(prb.numbers.I)],
        sp[:volume][i].out == sp[:volume][i].in - sp[:generation][i]
    )
    return nothing
end

function constraint_real_time_accepted!(sp::Model, prb::Problem, K::Int, T::Int)
    @constraint(
        sp,
        real_time_accepted[i=1:(prb.numbers.I)],
        sp[:generation][i] == sum(sp[:real_time_bid][k, i].in for k in 1:prb.numbers.Kᵦ if prb.cache.acceptance_real_time[K,k,i,T])
    )
    return nothing
end
