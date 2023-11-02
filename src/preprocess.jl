"""Evaluate the preprocess information"""
function preprocess!(prb::Problem)
    evaluate_acceptance_real_time!(prb)
    evaluate_acceptance_day_ahead!(prb)
    return nothing
end

"""Evaluate the acceptance matrix for real time prices"""
function evaluate_acceptance_real_time!(prb::Problem)
    numbers = prb.numbers
    random = prb.random_variables

    real_time = Array{Bool,4}(undef, numbers.Kᵦ, numbers.Kᵦ, numbers.I, numbers.T)

    for t in 1:(numbers.T), i in 1:(numbers.I), k in 1:(numbers.Kᵦ), kk in 1:(numbers.Kᵦ)
        real_time[kk, k, i, t] = random.πᵦ[k, i, t] <= random.πᵦ[kk, i, t]
    end
    prb.cache.acceptance_real_time = real_time

    return nothing
end

"""Evaluate the acceptance matrix for day ahead prices"""
function evaluate_acceptance_day_ahead!(prb::Problem)
    numbers = prb.numbers
    random = prb.random_variables

    day_ahead = Array{Bool,5}(
        undef, numbers.Kᵧ, numbers.Kᵧ, numbers.I, numbers.N, numbers.D
    )

    for d in 1:(numbers.D),
        n in 1:(numbers.N),
        i in 1:(numbers.I),
        k in 1:(numbers.Kᵧ),
        kk in 1:(numbers.Kᵧ)

        day_ahead[kk, k, i, n, d] = random.πᵧ[k, i, n, d] <= random.πᵧ[kk, i, n, d]
    end
    prb.cache.acceptance_day_ahead = day_ahead
    return nothing
end
