"""
    read_pjm_csv(path::String,
        column1::String,
        column2::String,
        column3::String,
        )

Returns a pivot table using column1 as rows, column2 as columns and column3 as values.
"""
function read_pjm_csv(path::String, column1::String, column2::String, column3::String)
    df = CSV.read(path, DataFrame)
    values1 = unique(df[!, column1])
    values2 = unique(df[!, column2])
    matrix = zeros(length(values1), length(values2))

    for row in eachrow(df)
        i = findfirst(isequal(row[column1]), values1)
        j = findfirst(isequal(row[column2]), values2)
        matrix[i, j] = row[column3]
    end

    return values1, values2, matrix
end

"""
    read_da_hrl_lmps(path::String)

Returns a pivot table of da_hrl_lmps using UTC date as rows, node id as columns and price as values.
"""
function read_da_hrl_lmps(path::String)
    return read_pjm_csv(path, "datetime_beginning_utc", "pnode_id", "system_energy_price_da")
end

"""
    read_rt_hrl_lmps(path::String)

    Returns a pivot table of rt_hrl_lmps using UTC date as rows, node id as columns and price as values.
"""
function read_rt_hrl_lmps(path::String)
    return read_pjm_csv(path, "datetime_beginning_utc", "pnode_id", "system_energy_price_rt")
end


