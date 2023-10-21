function constraint_copy_volume!(sp, prb::Problem)
    @constraint(
        sp,
        copy_volume[i=1:prb.numbers.I],
        sp[:volume][i].out == sp[:volume][i].in
    )
    return nothing
end

function constraint_copy_day_ahead_bid!(sp, prb::Problem)
    @constraint(
        sp,
        copy_day_ahead_bid[k=1:prb.numbers.Kᵦ, i=1:prb.numbers.I, n=1:prb.numbers.N],
        sp[:day_ahead_bid][k,i,n].out == sp[:day_ahead_bid][k,i,n].in
    )
    return nothing
end

function constraint_add_inflow!(sp, prb::Problem)
    @constraint(
        sp,
        add_inflow[i=1:prb.numbers.I],
        sp[:volume][i].out == sp[:volume][i].in + sp[:inflow][i]
    )
    return nothing
end

function constraint_real_time_bid_bound!(sp, prb::Problem)
    @constraint(
        sp,
        real_time_bid_bound[i=1:prb.numbers.I],
        sp[:volume][i].out >= sum(sp[:real_time_bid][k,i].out for k in 1:prb.numbers.Kᵦ)
    )
    return nothing
end

function constraint_add_generation!(sp, prb::Problem)
    @constraint(
        sp,
        constraint_add_generation![i=1:prb.numbers.I],
        sp[:volume][i].out == sp[:volume][i].in - sp[:generation][i]
    )
    return nothing
end

function constraint_real_time_accepted!(sp, prb::Problem, K::Int)
    @constraint(
        sp,
        real_time_accepted[i=1:prb.numbers.I],
        sp[:generation][i] == sum(sp[:real_time_bid][k,i].in for k in 1:K)
    )
    return nothing
end