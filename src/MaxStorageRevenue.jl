module MaxStorageRevenue

using JSON
using JSONSchema
using JuMP
using SDDP
using Match
using Plots

include("macros.jl")
include("structs.jl")
include("options.jl")
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
include("graph.jl")

export validate_json,
    create_problem,
    simulate!,
    build_model!,
    train!,
    Problem,
    plot_volumes,
    plot_spillages,
    plot_generations,
    plot_inflows,
    plot_real_time_bids,
    plot_day_ahead_clears,
    plot_day_ahead_bids,
    plot_all,
    set_optimizer!,
    set_operational_constraints!

end # module MaxStorageRevenue
