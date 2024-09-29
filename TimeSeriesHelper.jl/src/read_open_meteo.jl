"""
    read_open_meteo_json(directory::String,
        serie::String,
        start::Int,
        stop::Int
        )

Returns a dictionary with keys being the node id and values being a vector of wind.
"""
function read_open_meteo_json(directory::String, serie::String, start::Int, stop::Int)
    start_string = string(start)
    stop_string = string(stop)
    start_utc = start_string[1:4] * "-" * start_string[5:6] * "-" * start_string[7:8] * "T00:00"
    stop_utc = stop_string[1:4] * "-" * stop_string[5:6] * "-" * stop_string[7:8] * "T23:00"

    dict = Dict{String, Vector{Float64}}()
    for file_path in readdir(directory)
        if endswith(file_path, ".json")
            json_path = joinpath(directory, file_path)
            json = JSON.parse(String(read(json_path)))
            times = json["hourly"]["time"]
            data = json["hourly"][serie]
            vec = [data[i] for i in 1:length(times) if times[i] >= start_utc && times[i] <= stop_utc]
            key = file_path[1:end - 5]
            if !haskey(dict, key)
                dict[key] = vec
            else
                append!(dict[key], vec)
            end
        end
    end
    return dict
end