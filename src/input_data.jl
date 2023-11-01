const schema_path = joinpath(dirname(@__FILE__), "schemas", "problem.json")

function parse_file_json(file::String)
    return JSON.parse(String(read(file)))
end

function validate_json(file_path::String)
    return validate(Schema(parse_file_json(schema_path)), parse_file_json(file_path))
end

function create_problem(file::String)::Problem
    dict = parse_file_json(file)
    prb = Problem()

    write_numbers!(prb, dict)
    write_data!(prb, dict)
    write_random!(prb, dict)

    return prb
end

function write_numbers!(prb::Problem, dict::Dict)
    numbers = prb.numbers

    numbers.N = dict["numbers"]["periods_per_day"]
    numbers.n₀ = dict["numbers"]["first_period"]
    numbers.I = dict["numbers"]["units"]
    numbers.U = dict["numbers"]["period_of_day_ahead_bid"]
    numbers.V = dict["numbers"]["period_of_day_ahead_clear"]
    numbers.T = dict["numbers"]["duration"]
    numbers.Kᵦ = dict["numbers"]["prices_day_ahead_curve"]
    numbers.Kᵧ = dict["numbers"]["prices_real_time_curve"]
    numbers.Kᵪ = dict["numbers"]["inflows_scenarios"]
    numbers.D = Int(ceil(numbers.T / numbers.N))

    return nothing
end

function write_data!(prb::Problem, dict::Dict)
    data = prb.data

    data.V_max = dict["data"]["storage_max_capacity"]
    data.V_min = dict["data"]["storage_min_capacity"]
    data.V_0 = dict["data"]["storage_inicial_condition"]
    if haskey(dict["data"], "names")
        data.names = reshape(dict["data"]["names"], 1, prb.numbers.I)
    else
        temp = []
        for i in 1:(prb.numbers.I)
            push!(temp, "$i")
        end
        data.names = reshape(temp, 1, prb.numbers.I)
    end

    return nothing
end

function write_random!(prb::Problem, dict::Dict)
    random_variables = prb.random_variables
    numbers = prb.numbers

    random_variables.πᵦ = zeros(numbers.Kᵦ, numbers.I, numbers.T)
    random_variables.ωᵦ = zeros(numbers.Kᵦ, numbers.T)
    random_variables.πᵧ = zeros(numbers.Kᵧ, numbers.I, numbers.N, numbers.D)
    random_variables.ωᵧ = zeros(numbers.Kᵧ, numbers.D)
    random_variables.πᵪ = zeros(numbers.Kᵪ, numbers.I, numbers.T)
    random_variables.ωᵪ = zeros(numbers.Kᵪ, numbers.T)

    for t in 1:(numbers.T)
        for i in 1:(numbers.I)
            for k in 1:(numbers.Kᵦ)
                random_variables.πᵦ[k, i, t] = dict["random"]["prices_real_time"][t][i][k]
            end
            for k in 1:(numbers.Kᵪ)
                random_variables.πᵪ[k, i, t] = dict["random"]["inflow_values"][t][i][k]
            end
        end
        for k in 1:(numbers.Kᵦ)
            random_variables.ωᵦ[k, t] = dict["random"]["prob_real_time"][t][k]
        end
        for k in 1:(numbers.Kᵪ)
            random_variables.ωᵪ[k, t] = dict["random"]["prob_inflow"][t][k]
        end
    end

    for d in 1:(numbers.D), n in 1:(numbers.N), i in 1:(numbers.I), k in 1:(numbers.Kᵧ)
        random_variables.πᵧ[k, i, n, d] = dict["random"]["prices_day_ahead"][d][n][i][k]
    end

    for d in 1:(numbers.D), k in 1:(numbers.Kᵧ)
        random_variables.ωᵧ[k, d] = dict["random"]["prob_day_ahead"][d][k]
    end

    return nothing
end
