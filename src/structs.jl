"""Contains all possibles types of the problem"""
@enumx ProblemType begin
    NOT # nothing
    RTB # Real time bid
    RTC # Real time clear
    DAB # Day ahead bid
    DAC # Day ahead clear
end

"""Information about position and type of each subproblem"""
struct ProblemInfo
    problem_type::ProblemType.T
    t::Int
    k::Int
end

"""Contains all user options"""
Base.@kwdef mutable struct Options
    optimizer::Union{DataType,Nothing} = nothing
    use_ramp_up::Bool = false
    use_ramp_down::Bool = false
    use_day_ahead_bid_bound::Bool = true
    penalty_ramp_up::Float64 = 0.0
    penalty_ramp_down::Float64 = 0.0
end

"""Contains all flags, evaluated using options"""
Base.@kwdef mutable struct Flags
    generation_as_state::Bool = false
end

"""Contains all random variables"""
Base.@kwdef mutable struct RandomVariables
    πᵦ::Array{Float64,3} = Array{Float64}(undef, zeros(Int, 3)...) # Prices of real time (k,i,t)
    ωᵦ::Array{Float64,2} = Array{Float64}(undef, zeros(Int, 2)...) # Probabilities of real time (k,t)
    πᵧ::Array{Float64,4} = Array{Float64}(undef, zeros(Int, 4)...) # Prices of day ahead (k,i,n,d)
    ωᵧ::Array{Float64,2} = Array{Float64}(undef, zeros(Int, 2)...) # Probabilities of day ahead (k,t)
    πᵪ::Array{Float64,3} = Array{Float64}(undef, zeros(Int, 3)...) # Inflow values (j,i,t)
    ωᵪ::Array{Float64,2} = Array{Float64}(undef, zeros(Int, 2)...) # Probabilities of inflow (j,t)
end

"""Contains all sizes and indices"""
Base.@kwdef mutable struct Numbers
    N::Int  = 0 # Number of periods of time per day
    n₀::Int = 0 # First period of time
    I::Int  = 0 # Number of units
    U::Int  = 0 # Periods of day ahead bid
    V::Int  = 0 # Periods of day ahead clear
    D::Int  = 0 # Number of days 
    T::Int  = 0 # Number of periods of time in the horizon
    Kᵦ::Int = 0 # Number of prices in the real time curve
    Kᵧ::Int = 0 # Number of prices in the day ahead curve
    Kᵪ::Int = 0 # Number of inflow scenarios
end

"""Contains the cache data"""
Base.@kwdef mutable struct Cache
    problem_info::Dict{Int,ProblemInfo} = Dict{Int,ProblemInfo}()
    acceptance_real_time::Array{Bool,4} = Array{Bool}(undef, zeros(Int, 4)...)
    acceptance_day_ahead::Array{Bool,5} = Array{Bool}(undef, zeros(Int, 5)...)
end

"""Contains the storages and generators data"""
Base.@kwdef mutable struct Data
    volume_max::Vector{Float64}         = Array{Float64}(undef, zeros(Int, 1)...) # Storage max capacity
    volume_min::Vector{Float64}         = Array{Float64}(undef, zeros(Int, 1)...) # Storage min capacity
    volume_initial::Vector{Float64}     = Array{Float64}(undef, zeros(Int, 1)...) # Storage inicial condition
    ramp_up::Vector{Float64}            = Array{Float64}(undef, zeros(Int, 1)...) # ramp up generation (optional)
    ramp_down::Vector{Float64}          = Array{Float64}(undef, zeros(Int, 1)...) # ramp down generation (optional)
    generation_initial::Vector{Float64} = Array{Float64}(undef, zeros(Int, 1)...) # initial generation (optional)
    names::Matrix{String}               = Array{String}(undef, zeros(Int, 2)...) # Storage names (optional)
end

"""Contains all outputs"""
Base.@kwdef mutable struct Output
    objective::Array{Float64,1}       = Array{Float64}(undef, zeros(Int, 1)...)
    volume::Array{Float64,3}          = Array{Float64}(undef, zeros(Int, 3)...)
    real_time_bid::Array{Float64,4}   = Array{Float64}(undef, zeros(Int, 4)...)
    day_ahead_bid::Array{Float64,5}   = Array{Float64}(undef, zeros(Int, 5)...)
    day_ahead_clear::Array{Float64,4} = Array{Float64}(undef, zeros(Int, 4)...)
    inflow::Array{Float64,3}          = Array{Float64}(undef, zeros(Int, 3)...)
    generation::Array{Float64,3}      = Array{Float64}(undef, zeros(Int, 3)...)
    spillage::Array{Float64,3}        = Array{Float64}(undef, zeros(Int, 3)...)
end

"""Contains all the problem description"""
Base.@kwdef mutable struct Problem
    options::Options = Options()
    flags::Flags = Flags()
    random_variables::RandomVariables = RandomVariables()
    numbers::Numbers = Numbers()
    cache::Cache = Cache()
    data::Data = Data()
    output::Output = Output()
    model::Union{SDDP.PolicyGraph,Nothing} = nothing
end
