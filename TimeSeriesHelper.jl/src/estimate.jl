function build_serial_history(history::History, T::Int, P::Int)::Vector{Vector{Float64}}
    prices_real_time = history.prices_real_time
    prices_day_ahead = history.prices_day_ahead
    inflow = history.inflow

    serial_history = Vector{Vector{Float64}}(undef, T)
    for t in 1:T
        serial_history[t] = [
            prices_real_time[t]...,
            vcat(prices_day_ahead[t:(t + P - 1)]...)...,
            inflow[t]...,
        ]
    end
    return serial_history
end

function estimate_hmm(
    history::Vector{Vector{Float64}}, number_states::Int
)::Tuple{Matrix{Float64},Vector{Distribution}}
    dists = Vector{MvNormal}(undef, number_states)
    for i in 1:number_states
        dists[i] = MvNormal(history[24 * i], I) # TODO
    end
    hmm_guess = HMM(
        ones(number_states) / number_states,
        zeros(number_states, number_states) .+ 1 / number_states,
        dists,
    )
    hmm_est, _ = baum_welch(hmm_guess, history)

    return transition_matrix(hmm_est), obs_distributions(hmm_est)
end

function build_markov_transition(
    transition_matrix::Matrix{Float64}, T::Int
)::Vector{Matrix{Float64}}
    transitions_matrix = Vector{Matrix{Float64}}(undef, T)
    transitions_matrix[1] = sum(transition_matrix, dims=1) / size(transition_matrix, 1)
    for t in 2:T
        transitions_matrix[t] = transition_matrix
    end
    return transitions_matrix
end

function build_scenarios(
    obs_distributions::Vector{Distribution}, T::Int, P::Int, W::Int, U::Int, B::Int, I::Int
)
    N = length(obs_distributions)
    D = T ÷ P
    inflow = Vector{Vector{Vector{Vector{Float64}}}}(undef, T)
    prices_day_ahead = Vector{Vector{Vector{Vector{Float64}}}}(undef, D)
    prices_real_time = Vector{Vector{Vector{Float64}}}(undef, T)

    samples_real_time = zeros(T, N, B)
    samples_day_ahead = zeros(T, N, B * P)
    samples_inflow = zeros(T, N, W, I)
    for t in 1:T, n in 1:N, w in 1:W
        sample = rand(obs_distributions[n])
        samples_real_time[t, n, :] += sample[1:B] / W
        samples_day_ahead[t, n, :] += sample[(B + 1):(B * (P + 1))] / W
        samples_inflow[t, n, w, :] = sample[(B * (P + 1) + 1):end]
    end

    for t in 1:T
        temp = []
        for b in 1:B
            push!(temp, [])
            for n in 1:N
                push!(temp[b], sum(samples_real_time[t, n, b]))
            end
        end
        prices_real_time[t] = temp
    end

    for d in 1:D
        temp = []
        for p in 1:P
            push!(temp, [])
            for b in 1:(B)
                push!(temp[p], [])
                for n in 1:N
                    push!(
                        temp[p][b], samples_day_ahead[U + P * (d - 1), n, b + B * (p - 1)]
                    )
                end
            end
        end
        prices_day_ahead[d] = temp
    end

    for t in 1:T
        temp = []
        for n in 1:N
            push!(temp, [])
            for w in 1:W
                push!(temp[n], [])
                for i in 1:I
                    # TODO abs
                    push!(temp[n][w], abs(samples_inflow[t, n, w, i]))
                end
            end
        end
        inflow[t] = temp
    end
    return prices_real_time, prices_day_ahead, inflow
end
