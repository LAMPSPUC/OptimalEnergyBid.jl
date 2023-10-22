module MaxStorageRevenue

using SDDP
using Match

include("macros.jl")
include("enums.jl")
include("structs.jl")
include("build_graph.jl")
include("variables.jl")
include("constraints.jl")
include("objective.jl")
include("build_model.jl")
include("train_model.jl")
include("simulate_model.jl")

export simulate, build_model!, train!, Problem

end # module MaxStorageRevenue
