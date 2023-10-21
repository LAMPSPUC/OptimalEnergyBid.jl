using MaxStorageRevenue, Test
using JuMP, SDDP, Test

include("test_build_graph.jl")
include("test_build_model.jl")
include("test_train_model.jl")