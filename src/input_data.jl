const schema_path = joinpath(dirname(@__FILE__), "problem.json")

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
    numbers.V = dict["numbers"]["period_of_day_ahead_commit"]
    numbers.T = dict["numbers"]["duration"]
    numbers.Kᵦ = dict["numbers"]["prices_day_ahead_curve"]
    numbers.Kᵧ = dict["numbers"]["prices_real_time_curve"]
    numbers.Kᵪ = dict["numbers"]["inflows_scenarios"]

    return nothing
end

function write_data!(prb::Problem, dict::Dict)
    data = prb.data

    data.V_max = dict["data"]["storage_min_capacity"]
    data.V_min = dict["data"]["storage_max_capacity"]
    data.V_0 = dict["data"]["storage_inicial_condition"]

    return nothing
end

function write_random!(prb::Problem, dict::Dict)
    random_variables = prb.random_variables
    numbers = prb.numbers

    temp = Int(ceil(numbers.T / numbers.N))

    random_variables.πᵦ = zeros(numbers.Kᵦ, numbers.I, numbers.T)
    random_variables.ωᵦ = zeros(numbers.Kᵦ, numbers.T)
    random_variables.πᵧ = zeros(numbers.Kᵧ, numbers.I, temp, numbers.N)
    random_variables.ωᵧ = zeros(numbers.Kᵧ, temp)
    random_variables.πᵪ = zeros(numbers.Kᵪ, numbers.I, numbers.T)
    random_variables.ωᵪ = zeros(numbers.Kᵪ, numbers.T)

    for t in 1:numbers.T
        for i in 1:numbers.I
            for k in 1:numbers.Kᵦ
                random_variables.πᵦ[k,i,t] = dict["random"]["prices_real_time"][t][i][k]
            end
            for k in 1:numbers.Kᵪ
                random_variables.πᵪ[k,i,t] = dict["random"]["inflow_values"][t][i][k]
            end
        end
        for k in 1:numbers.Kᵦ
            random_variables.ωᵦ[k,t] = dict["random"]["prob_real_time"][t][k]
        end
        for k in 1:numbers.Kᵪ
            random_variables.ωᵪ[k,t] = dict["random"]["prob_inflow"][t][k]
        end
    end

    for n in 1:numbers.N, t in 1:temp, i in 1:numbers.I, k in 1:numbers.Kᵦ
        random_variables.πᵧ[k,i,t,n] = dict["random"]["prices_day_ahead"][n][t][i][k]
    end

    for t in 1:temp, k in 1:numbers.Kᵦ
        random_variables.ωᵧ[k,t] = dict["random"]["prob_day_ahead"][t][k]
    end

    return nothing
end
