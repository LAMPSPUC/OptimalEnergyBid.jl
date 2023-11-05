"""The json schema of the problem"""
const schema_path = joinpath(dirname(dirname(@__FILE__)), "schemas", "problem.json")

"""json file to dict"""
function _parse_file_json(file::String)
    return JSON.parse(String(read(file)))
end

"""Validates a json file"""
function validate_json(file_path::String)
    return validate(Schema(_parse_file_json(schema_path)), _parse_file_json(file_path))
end

"""Creates a problem using json information"""
function create_problem(file::String)::Problem
    dict = _parse_file_json(file)
    prb = Problem()

    _write_numbers!(prb, dict)
    _write_data!(prb, dict)
    _write_random!(prb, dict)

    return prb
end

"""Reads size and indeces information"""
function _write_numbers!(prb::Problem, dict::Dict)
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

"""Reads storage/generators data information"""
function _write_data!(prb::Problem, dict::Dict)
    data = prb.data

    data.volume_max = dict["data"]["volume_max"]
    data.volume_min = dict["data"]["volume_min"]
    data.volume_initial = dict["data"]["volume_initial"]
    if haskey(dict["data"], "names")
        data.names = dict["data"]["names"]
    else
        temp = []
        for i in 1:(prb.numbers.I)
            push!(temp, "$i")
        end
        data.names = temp
    end
    if haskey(dict["data"], "ramp_up")
        data.ramp_up = dict["data"]["ramp_up"]
    end
    if haskey(dict["data"], "ramp_down")
        data.ramp_up = dict["data"]["ramp_down"]
    end
    if haskey(dict["data"], "generation_initial")
        data.ramp_up = dict["data"]["generation_initial"]
    end

    return nothing
end

"""Reads random variables information"""
function _write_random!(prb::Problem, dict::Dict)
    random = prb.random
    numbers = prb.numbers

    random.πᵦ = zeros(numbers.Kᵦ, numbers.I, numbers.T)
    random.ωᵦ = zeros(numbers.Kᵦ, numbers.T)
    random.πᵧ = zeros(numbers.Kᵧ, numbers.I, numbers.N, numbers.D)
    random.ωᵧ = zeros(numbers.Kᵧ, numbers.D)
    random.πᵪ = zeros(numbers.Kᵪ, numbers.I, numbers.T)
    random.ωᵪ = zeros(numbers.Kᵪ, numbers.T)

    for t in 1:(numbers.T)
        for i in 1:(numbers.I)
            for k in 1:(numbers.Kᵦ)
                random.πᵦ[k, i, t] = dict["random"]["prices_real_time"][t][i][k]
            end
            for k in 1:(numbers.Kᵪ)
                random.πᵪ[k, i, t] = dict["random"]["inflow_values"][t][i][k]
            end
        end
        for k in 1:(numbers.Kᵦ)
            random.ωᵦ[k, t] = dict["random"]["prob_real_time"][t][k]
        end
        for k in 1:(numbers.Kᵪ)
            random.ωᵪ[k, t] = dict["random"]["prob_inflow"][t][k]
        end
    end

    for d in 1:(numbers.D), n in 1:(numbers.N), i in 1:(numbers.I), k in 1:(numbers.Kᵧ)
        random.πᵧ[k, i, n, d] = dict["random"]["prices_day_ahead"][d][n][i][k]
    end

    for d in 1:(numbers.D), k in 1:(numbers.Kᵧ)
        random.ωᵧ[k, d] = dict["random"]["prob_day_ahead"][d][k]
    end

    return nothing
end

names_map = Dict(
    "\"πᵦ\":" => "\"prices_real_time\":",
    "\"ωᵦ\":" => "\"prob_real_time\":",
    "\"πᵧ\":" => "\"prices_day_ahead\":",
    "\"ωᵧ\":" => "\"prob_day_ahead\":",
    "\"πᵪ\":" => "\"inflow_values\":",
    "\"ωᵪ\":" => "\"prob_inflow\":",
    
    "\"N\":" => "\"periods_per_day\":",
    "\"n₀\":" => "\"first_period\":",
    "\"I\":" => "\"units\":",
    "\"U\":" => "\"period_of_day_ahead_bid\":",
    "\"V\":" => "\"period_of_day_ahead_clear\":",
    "\"T\":" => "\"duration\":",
    "\"Kᵦ\":" => "\"prices_day_ahead_curve\":",
    "\"Kᵧ\":" => "\"prices_real_time_curve\":",
    "\"Kᵪ\":" => "\"inflows_scenarios\":"
)

function write_json(prb::Problem, file::String, names_map::Dict{String,String}=names_map)
    prb_temp = _copy_only_input(prb)
    string_data = JSON.json(prb_temp)
    index = findfirst(",\"flags\":", string_data)[1]
    string_data = string_data[1:index-1] * "}"
    string_data = _replace_names(string_data, names_map)
    open(file, "w") do f
        write(f, string_data)
    end
    return nothing
end

function _copy_only_input(prb::Problem)::Problem
    prb_temp = Problem()
    prb_temp.options = prb.options
    prb_temp.data = prb.data
    prb_temp.numbers = prb.numbers
    prb_temp.random = prb.random
    return prb_temp
end

function _replace_names(s::String, names_map::Dict{String,String})::String
    for key in keys(names_map)
        s = replace(s, key => names_map[key])
    end
    return s
end
