"""Evaluate the preprocess information"""
function _preprocess!(prb::Problem)
    _evaluate_acceptance_real_time!(prb)
    _evaluate_acceptance_day_ahead!(prb)
    return nothing
end

"""Evaluate the acceptance matrix for real time prices"""
function _evaluate_acceptance_real_time!(prb::Problem)
    numbers = prb.numbers
    random = prb.random
    data = prb.data

    real_time = []
    for t in 1:(numbers.T)
        temp = []
        for n in 1:(size(random.P[t])[2])
            matrix = zeros(numbers.I, numbers.Kᵦ)
            for i in 1:(numbers.I), k in 1:(numbers.Kᵦ)
                matrix[i, k] = random.πᵦ[t][i][n] <= data.pᵦ[t][i][k]
            end
            push!(temp, matrix)
        end
        push!(real_time, temp)
    end
    prb.cache.acceptance_real_time = real_time

    return nothing
end

"""Evaluate the acceptance matrix for day ahead prices"""
function _evaluate_acceptance_day_ahead!(prb::Problem)
    numbers = prb.numbers
    random = prb.random
    data = prb.data

    day_ahead = []
    for d in 1:(numbers.D)
        temp = []
        for j in 1:(numbers.N)
            temp1 = []
            for n in 1:(size(random.P[j + (numbers.N * (d - 1))])[2])
                matrix = zeros(numbers.I, numbers.Kᵧ)
                for i in 1:(numbers.I), k in 1:(numbers.Kᵧ)
                    matrix[i, k] = random.πᵧ[d][j][i][n] <= data.pᵧ[d][j][i][k]
                end
                push!(temp1, matrix)
            end
            push!(temp, temp1)
        end
        push!(day_ahead, temp)
    end
    prb.cache.acceptance_day_ahead = day_ahead

    return nothing
end
