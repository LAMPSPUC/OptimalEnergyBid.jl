function constraint_copy_volume!(sp, prb::Problem)
    @constraint(
        sp,
        copy_volume[i=1:prb.numbers.I],
        sp[:volume][i].out == sp[:volume][i].in
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
        sp[:volume][i].out >= sum(real_time_bid[:,i])
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