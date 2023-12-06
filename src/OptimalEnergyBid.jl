module OptimalEnergyBid

using EnumX
using JSON
using JSONSchema
using JuMP
using SDDP
using Match
using Plots

include("structs.jl")
include("options.jl")
include("input_data.jl")
include("preprocess.jl")
# include("variables.jl")
# include("constraints.jl")
# include("objective.jl")
# include("build_model.jl")
include("train_model.jl")
include("simulate_model.jl")

export validate_json,
    write_json,
    create_problem,
    simulate!,
    # build_model!,
    train!,
    Problem,
    set_optimizer!,
    set_bool_parameter!,
    set_float_parameter!,
    ParameterBool,
    ParameterFloat

end # module OptimalEnergyBid
