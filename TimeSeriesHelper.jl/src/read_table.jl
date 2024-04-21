"""
    read_generation_csv(path::String)

Returns a table.
"""
function read_generation_csv(path::String)
    df = CSV.read(path, DataFrame)
    values1 = unique(df[!, "datetime"])
    values2 = names(df)[2:end]
    matrix = zeros(length(values1), length(values2))

    for i in 1:length(values1), j in 1:length(values2)
        matrix[i, j] = df[i, j + 1]
    end

    return values1, values2, matrix
end

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
    return read_pjm_csv(path, "datetime_beginning_utc", "pnode_name", "total_lmp_da")
end

"""
    read_rt_hrl_lmps(path::String)

    Returns a pivot table of rt_hrl_lmps using UTC date as rows, node id as columns and price as values.
"""
function read_rt_hrl_lmps(path::String)
    return read_pjm_csv(path, "datetime_beginning_utc", "pnode_name", "total_lmp_rt")
end
