"""The json schema of the problem"""
const schema_path = joinpath(dirname(@__DIR__), "schemas", "problem.json")

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

    _read_options!(prb, dict)
    _read_numbers!(prb, dict)
    _read_data!(prb, dict)
    _read_random!(prb, dict)

    return prb
end

"""Reads size and indeces information"""
function _read_options!(prb::Problem, dict::Dict)
    options = prb.options

    options.use_ramp_up = dict["options"]["use_ramp_up"]
    options.use_ramp_down = dict["options"]["use_ramp_down"]
    options.use_day_ahead_bid_bound = dict["options"]["use_day_ahead_bid_bound"]
    options.penalty_ramp_down = dict["options"]["penalty_ramp_down"]

    return nothing
end

"""Reads size and indeces information"""
function _read_numbers!(prb::Problem, dict::Dict)
    numbers = prb.numbers

    numbers.N = dict["numbers"]["periods_per_day"]
    numbers.n₀ = dict["numbers"]["first_period"]
    numbers.I = dict["numbers"]["units"]
    numbers.U = dict["numbers"]["period_of_day_ahead_bid"]
    numbers.V = dict["numbers"]["period_of_day_ahead_clear"]
    numbers.T = dict["numbers"]["duration"]
    numbers.Kᵦ = dict["numbers"]["total_day_ahead_curve"]
    numbers.Kᵧ = dict["numbers"]["total_real_time_curve"]
    numbers.D = Int(ceil(numbers.T / numbers.N))

    return nothing
end

"""Reads storage/generators data information"""
function _read_data!(prb::Problem, dict::Dict)
    data = prb.data

    data.volume_max = dict["data"]["volume_max"]
    data.volume_min = dict["data"]["volume_min"]
    data.volume_initial = dict["data"]["volume_initial"]
    data.pᵦ = dict["data"]["prices_real_time_curve"]
    data.pᵧ = dict["data"]["prices_day_ahead_curve"]

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
        data.ramp_down = dict["data"]["ramp_down"]
    end
    if haskey(dict["data"], "generation_initial")
        data.generation_initial = dict["data"]["generation_initial"]
    end

    return nothing
end

"""Reads random variables information"""
function _read_random!(prb::Problem, dict::Dict)
    random = prb.random
    numbers = prb.numbers

    random.πᵦ = dict["random"]["prices_real_time"]
    random.πᵧ = dict["random"]["prices_day_ahead"]
    random.πᵪ = dict["random"]["inflow_values"]
    random.ωᵪ = dict["random"]["prob_inflow"]

    random.P = []

    for t in 1:(numbers.T)
        M = length(dict["random"]["markov_transitions"][t])
        N = length(dict["random"]["markov_transitions"][t][1])
        temp = zeros(M, N)
        for m in 1:(M), n in 1:(N)
            temp[m, n] = dict["random"]["markov_transitions"][t][m][n]
        end
        push!(random.P, temp)
    end

    return nothing
end

"""The map between the names in the struct and json"""
_names_map = Dict(
    "\"πᵦ\":" => "\"prices_real_time\":",
    "\"πᵧ\":" => "\"prices_day_ahead\":",
    "\"πᵪ\":" => "\"inflow_values\":",
    "\"ωᵪ\":" => "\"prob_inflow\":",
    "\"N\":" => "\"periods_per_day\":",
    "\"n₀\":" => "\"first_period\":",
    "\"I\":" => "\"units\":",
    "\"U\":" => "\"period_of_day_ahead_bid\":",
    "\"V\":" => "\"period_of_day_ahead_clear\":",
    "\"T\":" => "\"duration\":",
    "\"pᵦ\":" => "\"prices_real_time_curve\":",
    "\"pᵧ\":" => "\"prices_day_ahead_curve\":",
    "\"Kᵦ\":" => "\"total_real_time_curve\":",
    "\"Kᵧ\":" => "\"total_day_ahead_curve\":",
    "\"P\":" => "\"markov_transitions\":",
)

"""
    write_json(prb::Problem,
        file::String,
        )

Write all the input data present in "prb" to "file".
"""
function write_json(prb::Problem, file::String)
    prb_temp = _copy_only_input(prb)
    string_data = JSON.json(prb_temp)
    index = findfirst(",\"flags\":", string_data)[1]
    string_data = string_data[1:(index - 1)] * "}"
    string_data = _replace_names(string_data, _names_map)
    open(file, "w") do f
        write(f, string_data)
    end
    return nothing
end

"""Copy only the input"""
function _copy_only_input(prb::Problem)::Problem
    prb_temp = Problem()
    prb_temp.options = prb.options
    prb_temp.data = prb.data
    prb_temp.numbers = prb.numbers
    prb_temp.random = prb.random
    return prb_temp
end

"""Replace the names that are different in the json and structs"""
function _replace_names(s::String, _names_map::Dict{String,String})::String
    for key in keys(_names_map)
        s = replace(s, key => _names_map[key])
    end
    return s
end
