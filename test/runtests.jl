using MaxStorageRevenue
using SDDP, Test, HiGHS

include("test_build_graph.jl")
include("test_build_model.jl")
include("test_train_model.jl")