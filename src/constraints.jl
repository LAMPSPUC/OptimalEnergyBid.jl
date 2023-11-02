"""Adds the inflow random variable constraint"""
function constraint_inflow!(sp::Model, prb::Problem, t::Int)
    temp = [
        prb.random_variables.πᵪ[:, :, t][:, i] for
        i in 1:size(prb.random_variables.πᵪ[:, :, t], 2)
    ]
    SDDP.parameterize(sp, temp, prb.random_variables.ωᵪ[:, t]) do ω
        return JuMP.fix.(sp[:inflow], ω)
    end
end

"""Adds the copy volume constraint"""
function constraint_copy_volume!(sp::Model, prb::Problem)
    @constraint(
        sp, copy_volume[i=1:(prb.numbers.I)], sp[:volume][i].out == sp[:volume][i].in
    )
    return nothing
end

"""Adds the copy generation constraint"""
function constraint_copy_generation!(sp::Model, prb::Problem)
    @constraint(
        sp,
        copy_generation[i=1:(prb.numbers.I)],
        sp[:generation][i].out == sp[:generation][i].in
    )
    return nothing
end

"""Adds the generation ramp up constraint"""
function constraint_generation_ramp_up!(sp::Model, prb::Problem)
    @constraint(
        sp,
        generation_ramp_up[i=1:(prb.numbers.I)],
        sp[:ramp_up_violation][i] >=
            sp[:generation][i].out - sp[:generation][i].in - prb.data.ramp_up[i]
    )
    return nothing
end

"""Adds the generation ramp down constraint"""
function constraint_generation_ramp_down!(sp::Model, prb::Problem)
    @constraint(
        sp,
        generation_ramp_down[i=1:(prb.numbers.I)],
        sp[:ramp_down_violation][i] >=
            sp[:generation][i].in - sp[:generation][i].out - prb.data.ramp_down[i]
    )
    return nothing
end

"""Adds the copy day ahead bid constraint"""
function constraint_copy_day_ahead_bid!(sp::Model, prb::Problem)
    @constraint(
        sp,
        copy_day_ahead_bid[k=1:(prb.numbers.Kᵧ), i=1:(prb.numbers.I), n=1:(prb.numbers.N)],
        sp[:day_ahead_bid][k, i, n].out == sp[:day_ahead_bid][k, i, n].in
    )
    return nothing
end

"""Adds the copy day ahead clear constraint"""
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

"""Adds the shift day ahead clear constraint"""
function constraint_shift_day_ahead_clear!(sp::Model, prb::Problem)
    @constraint(
        sp,
        shift_day_ahead_clear[i=1:(prb.numbers.I), n=1:(2 * prb.numbers.N - prb.numbers.V)],
        sp[:day_ahead_clear][i, n].out == sp[:day_ahead_clear][i, n + 1].in
    )
    return nothing
end

"""Adds the day ahead clear constraint"""
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
        sp[:day_ahead_clear][i, n + prb.numbers.N - prb.numbers.V + 1].out == sum(
            sp[:day_ahead_bid][k, i, n].in for
            k in 1:(prb.numbers.Kᵧ) if prb.cache.acceptance_day_ahead[K, k, i, n, temp]
        )
    )
    return nothing
end

"""Adds the inflow constraint"""
function constraint_add_inflow!(sp::Model, prb::Problem)
    @constraint(
        sp,
        add_inflow[i=1:(prb.numbers.I)],
        sp[:volume][i].out == sp[:volume][i].in + sp[:inflow][i] - sp[:spillage][i]
    )
    return nothing
end

"""Adds the real time offer bound constraint"""
function constraint_real_time_bid_bound!(sp::Model, prb::Problem)
    @constraint(
        sp,
        real_time_bid_bound[i=1:(prb.numbers.I)],
        sp[:volume][i].out >= sum(sp[:real_time_bid][k, i].out for k in 1:(prb.numbers.Kᵦ))
    )
    return nothing
end

"""Adds the generatarion constraint using generatarion as a control variable"""
function constraint_add_generation!(sp::Model, prb::Problem)
    @constraint(
        sp,
        constraint_add_generation[i=1:(prb.numbers.I)],
        sp[:volume][i].out == sp[:volume][i].in - sp[:generation][i]
    )
    return nothing
end

"""Adds the real time accepted constraint using generatarion as a control variable"""
function constraint_real_time_accepted!(sp::Model, prb::Problem, K::Int, T::Int)
    @constraint(
        sp,
        real_time_accepted[i=1:(prb.numbers.I)],
        sp[:generation][i] == sum(
            sp[:real_time_bid][k, i].in for
            k in 1:(prb.numbers.Kᵦ) if prb.cache.acceptance_real_time[K, k, i, T]
        )
    )
    return nothing
end

"""Adds the generatarion constraint using generatarion as a state variable"""
function constraint_add_generation_state!(sp::Model, prb::Problem)
    @constraint(
        sp,
        constraint_add_generation_state[i=1:(prb.numbers.I)],
        sp[:volume][i].out == sp[:volume][i].in - sp[:generation][i].out
    )
    return nothing
end

"""Adds the real time accepted constraint using generatarion as a state variable"""
function constraint_real_time_accepted_state!(sp::Model, prb::Problem, K::Int, T::Int)
    @constraint(
        sp,
        real_time_accepted_state[i=1:(prb.numbers.I)],
        sp[:generation][i].out == sum(
            sp[:real_time_bid][k, i].in for
            k in 1:(prb.numbers.Kᵦ) if prb.cache.acceptance_real_time[K, k, i, T]
        )
    )
    return nothing
end
