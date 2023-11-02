variable_list = [
    :volume,
    :real_time_bid,
    :day_ahead_bid,
    :day_ahead_clear,
    :inflow,
    :generation,
    :spillage,
]

function write_output!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})
    write_day_ahead_bid!(prb, simul)
    write_day_ahead_clear!(prb, simul)
    write_real_time_bid!(prb, simul)
    write_volume!(prb, simul)
    write_generation!(prb, simul)
    write_spillage!(prb, simul)
    write_inflow!(prb, simul)
    return nothing
end

function write_day_ahead_bid!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})
    numbers = prb.numbers
    S = length(simul)
    day_ahead_bid = zeros(numbers.Kᵧ, numbers.I, numbers.N, numbers.D, S)

    for s in 1:S
        L = length(simul[s])
        d = 1
        for l in 1:L
            if prb.cache.problem_info[simul[s][l][:node_index]].problem_type == DAB
                for n in 1:(numbers.N), i in 1:(numbers.I), k in 1:(numbers.Kᵧ)
                    day_ahead_bid[k, i, n, d, s] = simul[s][l][:day_ahead_bid][k, i, n].out
                end
                d += 1
            end
        end
    end
    prb.output.day_ahead_bid = day_ahead_bid
    return nothing
end

function write_day_ahead_clear!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})
    numbers = prb.numbers
    S = length(simul)
    day_ahead_clear = zeros(numbers.I, numbers.N, numbers.D, S)

    for s in 1:S
        L = length(simul[s])
        d = 1
        for l in 1:L
            if prb.cache.problem_info[simul[s][l][:node_index]].problem_type == DAC
                for i in 1:(numbers.I), n in 1:(numbers.N)
                    day_ahead_clear[i, n, d, s] =
                        simul[s][l][:day_ahead_clear][
                            i, n + prb.numbers.N - prb.numbers.V + 1
                        ].out
                end
                d += 1
            end
        end
    end
    prb.output.day_ahead_clear = day_ahead_clear
    return nothing
end

function write_real_time_bid!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})
    numbers = prb.numbers
    S = length(simul)
    real_time_bid = zeros(numbers.Kᵦ, numbers.I, numbers.T, S)

    for s in 1:S
        L = length(simul[s])
        t = 1
        for l in 1:L
            if prb.cache.problem_info[simul[s][l][:node_index]].problem_type == RTB
                for i in 1:(numbers.I), k in 1:(numbers.Kᵦ)
                    real_time_bid[k, i, t, s] = simul[s][l][:real_time_bid][k, i].out
                end
                t += 1
            end
        end
    end
    prb.output.real_time_bid = real_time_bid
    return nothing
end

function write_volume!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})
    numbers = prb.numbers
    S = length(simul)
    volume = zeros(numbers.I, numbers.T, S)

    for s in 1:S
        L = length(simul[s])
        t = 1
        for l in 1:L
            if prb.cache.problem_info[simul[s][l][:node_index]].problem_type == RTC
                for i in 1:(numbers.I)
                    volume[i, t, s] = simul[s][l][:volume][i].out
                end
                t += 1
            end
        end
    end
    prb.output.volume = volume
    return nothing
end

function write_generation!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})
    numbers = prb.numbers
    S = length(simul)
    generation = zeros(numbers.I, numbers.T, S)

    for s in 1:S
        L = length(simul[s])
        t = 1
        for l in 1:L
            if prb.cache.problem_info[simul[s][l][:node_index]].problem_type == RTC
                if prb.flags.generation_as_state
                    for i in prb.numbers.I
                        generation[i, t, s] = simul[s][l][:generation][i].out
                    end
                else
                    generation[:, t, s] = simul[s][l][:generation]
                end
                t += 1
            end
        end
    end
    prb.output.generation = generation
    return nothing
end

function write_spillage!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})
    numbers = prb.numbers
    S = length(simul)
    spillage = zeros(numbers.I, numbers.T, S)

    for s in 1:S
        L = length(simul[s])
        t = 1
        for l in 1:L
            if prb.cache.problem_info[simul[s][l][:node_index]].problem_type == RTB
                spillage[:, t, s] = simul[s][l][:spillage]
                t += 1
            end
        end
    end
    prb.output.spillage = spillage
    return nothing
end

function write_inflow!(prb::Problem, simul::Vector{Vector{Dict{Symbol,Any}}})
    numbers = prb.numbers
    S = length(simul)
    inflow = zeros(numbers.I, numbers.T, S)

    for s in 1:S
        L = length(simul[s])
        t = 1
        for l in 1:L
            if prb.cache.problem_info[simul[s][l][:node_index]].problem_type == RTB
                inflow[:, t, s] = simul[s][l][:inflow]
                t += 1
            end
        end
    end
    prb.output.inflow = inflow
    return nothing
end
