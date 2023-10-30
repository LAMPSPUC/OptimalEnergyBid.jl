module MaxStorageRevenue

using JSON
using JSONSchema
using JuMP
using SDDP
using Match

include("macros.jl")
include("structs.jl")
include("input_data.jl")
include("preprocess.jl")
include("build_graph.jl")
include("variables.jl")
include("constraints.jl")
include("objective.jl")
include("build_model.jl")
include("train_model.jl")
include("output.jl")
include("simulate_model.jl")

export validate_json, create_problem, simulate!, build_model!, train!, Problem

end # module MaxStorageRevenue
