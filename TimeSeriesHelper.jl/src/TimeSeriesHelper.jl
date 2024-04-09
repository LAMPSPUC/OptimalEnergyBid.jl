module TimeSeriesHelper

using Distributions
using HiddenMarkovModels
using LinearAlgebra
using Random
using CSV
using DataFrames

Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

include("structs.jl")
include("read_table.jl")
include("estimate.jl")


end # module TimeSeriesHelper
