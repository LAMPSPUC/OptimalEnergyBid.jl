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

end # module MaxStorageRevenue
