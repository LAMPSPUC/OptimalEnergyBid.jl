"""Adds the inflow random variable constraint"""
function _constraint_inflow!(sp::Model, prb::Problem, t::Int, markov_state::Int)::Nothing
    SDDP.parameterize(
        sp,
        prb.random.inflow[t][markov_state],
        prb.random.inflow_probability[t][markov_state],
    ) do ω
        return JuMP.fix.(sp[:inflow], ω)
    end
    return nothing
end

"""Adds the generation ramp down constraint"""
function _constraint_ramp_down!(sp::Model, prb::Problem)::Nothing
    @constraint(
        sp,
        ramp_down[i=1:(prb.numbers.units)],
        sp[:ramp_down_violation][i] >=
            sp[:generation][i].in - sp[:generation][i].out - prb.data.ramp_down[i]
    )
    return nothing
end

"""Adds the copy day ahead bid constraint"""
function _constraint_copy_day_ahead_bid!(sp::Model, prb::Problem)::Nothing
    @constraint(
        sp,
        copy_day_ahead_bid[
            k=1:(prb.numbers.day_ahead_steps),
            i=1:(prb.numbers.units),
            n=1:(prb.numbers.periods_per_day),
        ],
        sp[:day_ahead_bid][k, i, n].out == sp[:day_ahead_bid][k, i, n].in
    )
    return nothing
end

"""Adds the bound day ahead bid constraint"""
function _constraint_bound_day_ahead_bid!(sp::Model, prb::Problem)::Nothing

    bound = zeros(prb.numbers.units)
    for t in 1:prb.numbers.duration
        for markov_state in 1:length(prb.random.inflow[t])
            for w in 1:length(prb.random.inflow[t][markov_state])
                for i in 1:(prb.numbers.units)
                    bound[i] = max(bound[i], prb.random.inflow[t][markov_state][w][i])
                end
            end
        end
    end

    @constraint(
        sp,
        bound_day_ahead_bid[i=1:(prb.numbers.units), n=1:(prb.numbers.periods_per_day)],
        sum(sp[:day_ahead_bid][k, i, n].out for k in 1:(prb.numbers.day_ahead_steps)) <= prb.data.volume_max[i]
    )
    return nothing
end

"""Adds the shift day ahead clear constraint"""
function _constraint_shift_day_ahead_clear!(sp::Model, prb::Problem)::Nothing
    @constraint(
        sp,
        shift_day_ahead_clear[
            i=1:(prb.numbers.units),
            n=1:(2 * prb.numbers.periods_per_day - prb.numbers.period_of_day_ahead_clear - 1),
        ],
        sp[:day_ahead_clear][i, n].out == sp[:day_ahead_clear][i, n + 1].in
    )
    return nothing
end

"""Adds the day ahead clear constraint"""
function _constraint_add_day_ahead_clear!(
    sp::Model, prb::Problem, t::Int, markov_state::Int
)::Nothing
    temp = div(t - 1, prb.numbers.periods_per_day) + 1
    @constraint(
        sp,
        keep_day_ahead_clear[
            i=1:(prb.numbers.units),
            n=1:(prb.numbers.periods_per_day - prb.numbers.period_of_day_ahead_clear),
        ],
        sp[:day_ahead_clear][i, n].out == sp[:day_ahead_clear][i, n + 1].in
    )
    @constraint(
        sp,
        add_shift_day_ahead_clear[
            i=1:(prb.numbers.units), n=1:(prb.numbers.periods_per_day)
        ],
        sp[:day_ahead_clear][
            i, n + prb.numbers.periods_per_day - prb.numbers.period_of_day_ahead_clear
        ].out == sum(
            sp[:day_ahead_bid][k, i, n].in for k in 1:(prb.numbers.day_ahead_steps) if
            prb.cache.acceptance_day_ahead[temp][n][markov_state][i, k]
        )
    )
    return nothing
end

"""Adds the real time offer bound constraint"""
function _constraint_real_time_bid_bound!(
    sp::Model, prb::Problem, t::Int, markov_state::Int
)::Nothing
    bound = zeros(prb.numbers.units) .+ Inf
    for w in 1:length(prb.random.inflow[t][markov_state])
        for i in 1:(prb.numbers.units)
            bound[i] = min(bound[i], prb.random.inflow[t][markov_state][w][i])
        end
    end

    @constraint(
        sp,
        real_time_bid_bound[i=1:(prb.numbers.units)],
        sp[:volume][i].out - prb.data.volume_min[i] + bound[i] >=
            sum(sp[:real_time_bid][k, i].out for k in 1:(prb.numbers.real_time_steps))
    )
    return nothing
end

"""Adds the ramp up offer bound constraint"""
function _constraint_ramp_up!(sp::Model, prb::Problem)::Nothing
    @constraint(
        sp,
        ramp_up[i=1:(prb.numbers.units)],
        prb.data.ramp_up[i] >=
            sum(sp[:real_time_bid][k, i].out for k in 1:(prb.numbers.real_time_steps)) -
        sp[:generation][i].out
    )
    return nothing
end

"""Adds the generatarion constraint using generatarion as a control variable"""
function _constraint_volume_balance!(sp::Model, prb::Problem)::Nothing
    @constraint(
        sp,
        constraint_add_generation[i=1:(prb.numbers.units)],
        sp[:volume][i].out ==
            sp[:volume][i].in - sp[:generation][i] + sp[:inflow][i] - sp[:spillage][i]
    )
    return nothing
end

"""Adds the real time accepted constraint using generatarion as a control variable"""
function _constraint_real_time_accepted!(
    sp::Model, prb::Problem, t::Int, markov_state::Int
)::Nothing
    @constraint(
        sp,
        real_time_accepted[i=1:(prb.numbers.units)],
        sp[:generation][i] == sum(
            sp[:real_time_bid][k, i].in for k in 1:(prb.numbers.real_time_steps) if
            prb.cache.acceptance_real_time[t][markov_state][i, k]
        )
    )
    return nothing
end

"""Adds the generatarion constraint using generatarion as a state variable"""
function _constraint_volume_balance_state!(sp::Model, prb::Problem)::Nothing
    @constraint(
        sp,
        constraint_add_generation_state[i=1:(prb.numbers.units)],
        sp[:volume][i].out ==
            sp[:volume][i].in - sp[:generation][i].out + sp[:inflow][i] - sp[:spillage][i]
    )
    return nothing
end

"""Adds the real time accepted constraint using generatarion as a state variable"""
function _constraint_real_time_accepted_state!(
    sp::Model, prb::Problem, t::Int, markov_state::Int
)::Nothing
    @constraint(
        sp,
        real_time_accepted_state[i=1:(prb.numbers.units)],
        sp[:generation][i].out == sum(
            sp[:real_time_bid][k, i].in for k in 1:(prb.numbers.real_time_steps) if
            prb.cache.acceptance_real_time[t][markov_state][i, k]
        )
    )
    return nothing
end
