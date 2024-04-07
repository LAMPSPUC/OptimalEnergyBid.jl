"""Evaluate the preprocess information"""
function _preprocess!(prb::Problem)::Nothing
    _evaluate_acceptance_real_time!(prb)
    _evaluate_acceptance_day_ahead!(prb)
    return nothing
end

"""Evaluate the acceptance matrix for real time prices"""
function _evaluate_acceptance_real_time!(prb::Problem)::Nothing
    numbers = prb.numbers
    random = prb.random
    data = prb.data

    real_time = []
    for t in 1:(numbers.duration)
        temp = []
        for n in 1:(size(random.markov_transitions[t])[2])
            matrix = zeros(numbers.units, numbers.real_tume_steps)
            for i in 1:(numbers.units), k in 1:(numbers.real_tume_steps)
                matrix[i, k] =
                    data.prices_real_time_curve[t][i][k] <= random.prices_real_time[t][prb.data.unit_to_bus[i]][n]
            end
            push!(temp, matrix)
        end
        push!(real_time, temp)
    end
    prb.cache.acceptance_real_time = real_time

    return nothing
end

"""Evaluate the acceptance matrix for day ahead prices"""
function _evaluate_acceptance_day_ahead!(prb::Problem)::Nothing
    numbers = prb.numbers
    random = prb.random
    data = prb.data

    day_ahead = []
    for d in 1:(numbers.days)
        temp = []
        for j in 1:(numbers.periods_per_day)
            temp1 = []
            for n in
                1:(size(
                random.markov_transitions[j + (numbers.periods_per_day * (d - 1))]
            )[2])
                matrix = zeros(numbers.units, numbers.day_ahead_steps)
                for i in 1:(numbers.units), k in 1:(numbers.day_ahead_steps)
                    matrix[i, k] =
                        data.prices_day_ahead_curve[d][j][i][k] <=
                        random.prices_day_ahead[d][j][prb.data.unit_to_bus[i]][n]
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
