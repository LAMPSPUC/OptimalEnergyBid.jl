"""The json schema of the problem"""
const schema_path = joinpath(dirname(@__DIR__), "schemas", "problem.json")

"""json file to dict"""
function _parse_file_json(file::String)::Dict
    return JSON.parse(String(read(file)))
end

"""Validates a json file"""
function validate_json(file_path::String)::Union{JSONSchema.SingleIssue,Nothing}
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
function _read_options!(prb::Problem, dict::Dict)::Nothing
    prb.options = convertdict(Options, dict["options"])
    return nothing
end

"""Reads size and indeces information"""
function _read_numbers!(prb::Problem, dict::Dict)::Nothing
    prb.numbers = convertdict(Numbers, dict["numbers"])
    prb.numbers.days = Int(ceil(prb.numbers.duration / prb.numbers.periods_per_day))

    return nothing
end

"""Reads storage/generators data information"""
function _read_data!(prb::Problem, dict::Dict)::Nothing
    prb.data = convertdict(Data, dict["data"])
    if prb.data.names == []
        for i in 1:(prb.numbers.units)
            push!(prb.data.names, "$i")
        end
    end
    return nothing
end

"""Reads random variables information"""
function _read_random!(prb::Problem, dict::Dict)::Nothing
    markov_transitions = dict["random"]["markov_transitions"]
    delete!(dict["random"], "markov_transitions")
    prb.random = convertdict(Random, dict["random"])
    for t in 1:(prb.numbers.duration)
        M = length(markov_transitions[t])
        N = length(markov_transitions[t][1])
        temp = zeros(M, N)
        for m in 1:(M), n in 1:(N)
            temp[m, n] = markov_transitions[t][m][n]
        end
        push!(prb.random.markov_transitions, temp)
    end

    return nothing
end

"""
    write_json(prb::Problem,
        file::String,
        )

Write all the input data present in "prb" to "file".
"""
function write_json(prb::Problem, file::String)::Nothing
    prb_serialized = _copy_only_input(prb)
    string_data = JSON.json(prb_serialized)
    open(file, "w") do f
        write(f, string_data)
    end
    return nothing
end

"""Copy only the input"""
function _copy_only_input(prb::Problem)::ProblemSerialized
    prb_serialized = ProblemSerialized()
    prb_serialized.options = prb.options
    prb_serialized.data = prb.data
    prb_serialized.numbers = prb.numbers
    prb_serialized.random = prb.random
    return prb_serialized
end
