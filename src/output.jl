"""Get all output data"""
function _write_output!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})::Nothing
    _write_day_ahead_bid!(prb, simul)
    _write_day_ahead_clear!(prb, simul)
    _write_real_time_bid!(prb, simul)
    _write_volume!(prb, simul)
    _write_generation!(prb, simul)
    _write_spillage!(prb, simul)
    _write_inflow!(prb, simul)
    _write_ramp_down_violation!(prb, simul)
    return nothing
end

"""Get the day ahead offer"""
function _write_day_ahead_bid!(
    prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}}
)::Nothing
    numbers = prb.numbers
    S = length(simul)
    day_ahead_bid = zeros(numbers.Kᵧ, numbers.I, numbers.N, numbers.D, S)

    for s in 1:S, t in 1:(numbers.T)
        if _is_clear_day_ahead(numbers, t)
            for n in 1:(numbers.N), i in 1:(numbers.I), k in 1:(numbers.Kᵧ)
                d = div(t - numbers.V + numbers.n₀ - 1, numbers.N) + 1
                day_ahead_bid[k, i, n, d, s] = simul[s][t][:day_ahead_bid][k, i, n].out
            end
        end
    end

    prb.output.day_ahead_bid = day_ahead_bid
    return nothing
end

"""Get the day ahead clear"""
function _write_day_ahead_clear!(
    prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}}
)::Nothing
    numbers = prb.numbers
    S = length(simul)
    day_ahead_clear = zeros(numbers.I, numbers.N, numbers.D, S)

    for s in 1:S, t in 1:(numbers.T)
        if _is_clear_day_ahead(numbers, t)
            for n in 1:(numbers.N), i in 1:(numbers.I)
                d = div(t - numbers.V + numbers.n₀ - 1, numbers.N) + 1
                day_ahead_clear[i, n, d, s] =
                    simul[s][t][:day_ahead_clear][i, n + prb.numbers.N - prb.numbers.V].out
            end
        end
    end

    prb.output.day_ahead_clear = day_ahead_clear
    return nothing
end

"""Get the real time offer"""
function _write_real_time_bid!(
    prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}}
)::Nothing
    numbers = prb.numbers
    S = length(simul)
    real_time_bid = zeros(numbers.Kᵦ, numbers.I, numbers.T, S)

    for s in 1:S, t in 1:(numbers.T), i in 1:(numbers.I), k in 1:(numbers.Kᵦ)
        real_time_bid[k, i, t, s] = simul[s][t][:real_time_bid][k, i].out
    end

    prb.output.real_time_bid = real_time_bid
    return nothing
end

"""Get the volume"""
function _write_volume!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})::Nothing
    numbers = prb.numbers
    S = length(simul)
    volume = zeros(numbers.I, numbers.T, S)

    for s in 1:S, t in 1:(numbers.T), i in 1:(numbers.I)
        volume[i, t, s] = simul[s][t][:volume][i].out
    end
    prb.output.volume = volume
    return nothing
end

"""Get the generation"""
function _write_generation!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})::Nothing
    numbers = prb.numbers
    S = length(simul)
    generation = zeros(numbers.I, numbers.T, S)

    for s in 1:S, t in 1:(numbers.T)
        if prb.flags.generation_as_state
            for i in 1:(prb.numbers.I)
                generation[i, t, s] = simul[s][t][:generation][i].out
            end
        else
            generation[:, t, s] = simul[s][t][:generation]
        end
    end

    prb.output.generation = generation
    return nothing
end

"""Get the spillage"""
function _write_spillage!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})::Nothing
    numbers = prb.numbers
    S = length(simul)
    spillage = zeros(numbers.I, numbers.T, S)

    for s in 1:S, t in 1:(numbers.T)
        spillage[:, t, s] = simul[s][t][:spillage]
    end
    prb.output.spillage = spillage
    return nothing
end

"""Get the inflow"""
function _write_inflow!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})::Nothing
    numbers = prb.numbers
    S = length(simul)
    inflow = zeros(numbers.I, numbers.T, S)

    for s in 1:S, t in 1:(numbers.T)
        inflow[:, t, s] = simul[s][t][:inflow]
    end
    prb.output.inflow = inflow
    return nothing
end

"""Get the ramp down violation"""
function _write_ramp_down_violation!(
    prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}}
)::Nothing
    if prb.options.use_ramp_down
        numbers = prb.numbers
        S = length(simul)
        ramp_down_violation = zeros(numbers.I, numbers.T, S)

        for s in 1:S, t in 1:(numbers.T)
            ramp_down_violation[:, t, s] = simul[s][t][:ramp_down_violation]
        end
        prb.output.ramp_down_violation = ramp_down_violation
    end
    return nothing
end
