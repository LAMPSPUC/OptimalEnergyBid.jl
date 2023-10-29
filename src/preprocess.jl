function preprocess!(prb::Problem)
    evaluate_acceptance_real_time!(prb)
    evaluate_acceptance_day_ahead!(prb)
    return nothing
end

function evaluate_acceptance_real_time!(prb::Problem)
    numbers = prb.numbers
    random = prb.random_variables

    real_time = Array{Bool, 4}(undef, numbers.Kᵦ, numbers.Kᵦ, numbers.I, numbers.T)

    for t in 1:numbers.T, i in 1:numbers.I, k in 1:numbers.Kᵦ, kk in 1:numbers.Kᵦ
        real_time[kk,k,i,t] = random.πᵦ[k,i,t] <= random.πᵦ[kk,i,t]
    end
    prb.cache.acceptance_real_time = real_time

    return nothing
end

function evaluate_acceptance_day_ahead!(prb::Problem)
    numbers = prb.numbers
    random = prb.random_variables

    temp = Int(ceil(numbers.T / numbers.N))

    day_ahead = Array{Bool, 5}(undef, numbers.Kᵧ, numbers.Kᵧ, numbers.I, temp, numbers.N)

    for n in 1:numbers.N, t in 1:temp, i in 1:numbers.I, k in 1:numbers.Kᵧ, kk in 1:numbers.Kᵧ
        day_ahead[kk,k,i,t,n] = random.πᵧ[k,i,t,n] <= random.πᵧ[kk,i,t,n]
    end
    prb.cache.acceptance_day_ahead = day_ahead
    return nothing
end