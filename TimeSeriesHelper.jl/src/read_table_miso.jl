function _download_csv(url, filename)
    response = HTTP.get(url)
    open(filename, "w") do file
        write(file, response.body)
    end
end

"""
    read_miso_csv(directory::String,
        file_pattern::String,
        start::Int,
        stop::Int
        )

Returns a dictionary with keys being the node id and values being a vector of prices.
"""
function read_miso_csv(directory::String, file_pattern::String, start::Int, stop::Int)
    dict = Dict{String,Vector{Float64}}()
    for i in start:stop
        file_path = joinpath(directory, string(i) * file_pattern)
        if !isfile(file_path)
            url = joinpath(
                "https://docs.misoenergy.org/marketreports", string(i) * file_pattern
            )
            task = @async _download_csv(url, file_path)
            wait(task)
        end
        df = CSV.read(file_path, DataFrame)[4:end, :]
        for row in eachrow(df)
            if (row[3] != "LMP")
                continue
            end
            vec = [parse(Float64, x) for x in values(row[4:27])]
            if !haskey(dict, row[1])
                dict[row[1]] = vec
            else
                append!(dict[row[1]], vec)
            end
        end
    end
    return dict
end

"""
        read_miso_da_lmps(directory::String,
            start::Int,
            stop::Int
        )

Returns a dictionary with keys being the node id and values being a vector of prices.
"""
function read_miso_da_lmps(directory::String, start::Int, stop::Int)
    return read_miso_csv(directory, "_da_expost_lmp.csv", start, stop)
end

"""
        read_miso_rt_lmps(directory::String,
            start::Int,
            stop::Int
        )

Returns a dictionary with keys being the node id and values being a vector of prices.
"""
function read_miso_rt_lmps(directory::String, start::Int, stop::Int)
    return read_miso_csv(directory, "_rt_lmp_final.csv", start, stop)
end
