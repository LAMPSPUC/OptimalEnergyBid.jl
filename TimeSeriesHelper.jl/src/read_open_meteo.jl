"""
    read_open_meteo_json(serie::String, start::DateTime, stop::DateTime, coordinates::Vector{Tuple{String, String}})

Returns a dictionary with keys being the coordinate and values being a time series.
"""
function read_open_meteo_json(
    serie::String,
    start::DateTime,
    stop::DateTime,
    coordinates::Vector{Tuple{String,String}},
)
    start_string = Dates.format(start, "yyyy-mm-dd")
    stop_string = Dates.format(stop, "yyyy-mm-dd")
    dict = Dict{Tuple{String,String},Vector{Float64}}()
    for coordinate in coordinates
        latitude = coordinate[1]
        longitude = coordinate[2]
        url =
            "https://archive-api.open-meteo.com/v1/era5?latitude=" *
            latitude *
            "&longitude=" *
            longitude *
            "&start_date=" *
            start_string *
            "&end_date=" *
            stop_string *
            "&hourly=" *
            serie
        json = JSON.parse(String(HTTP.get(url).body))
        times = json["hourly"]["time"]
        data = json["hourly"][serie]
        vec = [data[i] for i in 1:length(times)]
        dict[coordinate] = vec
    end
    return dict
end
