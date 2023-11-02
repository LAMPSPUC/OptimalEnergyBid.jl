using MaxStorageRevenue
using SDDP, Test, HiGHS

include("test_validate_json.jl")
include("test_create_prb.jl")
include("test_preprocess.jl")
include("test_build_graph.jl")
include("test_build_model.jl")
include("test_train_model.jl")
