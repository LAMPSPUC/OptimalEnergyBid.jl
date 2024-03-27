module OptimalEnergyBid

using EnumX
using StructMapping
using JSON
using JSONSchema
using JuMP
using SDDP
using Plots

include("structs.jl")
include("options.jl")
include("input_data.jl")
include("preprocess.jl")
include("variables.jl")
include("constraints.jl")
include("objective.jl")
include("build.jl")
include("solve.jl")
include("output.jl")
include("graph.jl")

end # module OptimalEnergyBid
