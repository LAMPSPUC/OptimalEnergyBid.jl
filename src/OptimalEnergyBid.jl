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
include("variables.jl")
include("constraints.jl")
include("objective.jl")
include("build.jl")
include("solve.jl")
include("output.jl")
include("graph.jl")

export validate_json,
    write_json,
    create_problem,
    simulate!,
    validate_problem!,
    build_model!,
    train!,
    Problem,
    set_optimizer!,
    set_bool_parameter!,
    set_float_parameter!,
    ParameterBool,
    ParameterFloat,
    plot_output,
    plot_all,
    OutputType

end # module OptimalEnergyBid
