function build_serial_history(history::History, T::Int, P::Int)::Vector{Vector{Float64}}
    prices_real_time = history.prices_real_time
    prices_day_ahead = history.prices_day_ahead
    inflow = history.inflow

    serial_history = Vector{Vector{Float64}}(undef, T)
    for t in 1:T
        serial_history[t] = [prices_real_time[t]..., vcat(prices_day_ahead[t:t+P]...)..., inflow[t]...]
    end
    return serial_history
end

function estimate_hmm(history::Vector{Vector{Float64}}, number_states::Int)::Tuple{Matrix{Float64}, Vector{Distribution}}
    dists = Vector{MvNormal}(undef, number_states)
    for i in 1:number_states
        dists[i] = MvNormal(ones(length(history[1])), I)
    end
    hmm_guess = HMM(ones(number_states)/number_states, Matrix{Float64}(I,number_states,number_states), dists)
    #hmm_est, _ = baum_welch(hmm_guess, history);
    return transition_matrix(hmm_guess), obs_distributions(hmm_guess)
    #return transition_matrix(hmm_est), obs_distributions(hmm_est)
end

function build_markov_transition(transition_matrix::Matrix{Float64}, T::Int)::Vector{Matrix{Float64}}
    transitions_matrix = Vector{Matrix{Float64}}(undef, T)
    for t in 1:T
        transitions_matrix[t] = transition_matrix
    end
    return transitions_matrix
end

function build_prices_real_time(obs_distributions::Vector{Distribution}, T::Int, P::Int)::Vector{Vector{Vector{Float64}}}
    prices_real_time = Vector{Vector{Vector{Float64}}}(undef, T)
    I = length(obs_distributions[1].μ) ÷ (P+2)
    N = length(obs_distributions) 

    temp = []
    for i in 1:I
        push!(temp, [])
        for n in 1:N
            push!(temp[i], obs_distributions[n].μ[i])
        end
    end
    
    for t in 1:T
        prices_real_time[t] = temp
    end
    return prices_real_time
end

function build_prices_day_ahead(obs_distributions::Vector{Distribution}, T::Int, P::Int)::Vector{Vector{Vector{Vector{Float64}}}}
    prices_day_ahead = Vector{Vector{Vector{Vector{Float64}}}}(undef, T)
    I = length(obs_distributions[1].μ) ÷ (P+2)
    N = length(obs_distributions) 

    temp = []
    for i in (I+1):(I*(P+1))
        push!(temp, [])
        for n in 1:N
            push!(temp[i], obs_distributions[n].μ[i])
        end
    end
    
    for t in 1:T
        prices_day_ahead[t] = temp
    end
    return prices_day_ahead
end

function build_inflow(obs_distributions::Vector{Distribution}, T::Int, P::Int, W::Int)::Vector{Vector{Vector{Vector{Float64}}}}
    inflow = Vector{Vector{Vector{Vector{Float64}}}}(undef, T)
    I = length(obs_distributions[1].μ) ÷ (P+2)
    N = length(obs_distributions) 

    temp = []
    for n in 1:N
        push!(temp, [])
        for w in 1:W
            push!(temp[n], [])
            random = rand(obs_distributions[n])
            for i in (I*(P+1)+1):(I*(P+2))
                push!(temp[n][w], random[i])
            end
        end
    end
    
    for t in 1:T
        inflow[t] = temp
    end
    return inflow
end