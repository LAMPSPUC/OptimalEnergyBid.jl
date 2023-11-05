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
@kwdef mutable struct Options
    optimizer::Union{DataType,Nothing} = nothing
    use_ramp_up::Bool = false
    use_ramp_down::Bool = false
    use_day_ahead_bid_bound::Bool = false
    penalty_ramp_up::Float64
    penalty_ramp_down::Float64
end

"""Contains all flags, evaluated using options"""
@kwdef mutable struct Flags
    generation_as_state::Bool = false
end

"""Contains all random variables"""
@kwdef mutable struct RandomVariables
    πᵦ::Array{Float64,3} # Prices of real time (k,i,t)
    ωᵦ::Array{Float64,2} # Probabilities of real time (k,t)
    πᵧ::Array{Float64,4} # Prices of day ahead (k,i,n,d)
    ωᵧ::Array{Float64,2} # Probabilities of day ahead (k,t)
    πᵪ::Array{Float64,3} # Inflow values (j,i,t)
    ωᵪ::Array{Float64,2} # Probabilities of inflow (j,t)
end

"""Contains all sizes and indices"""
@kwdef mutable struct Numbers
    N::Int # Number of periods of time per day
    n₀::Int # First period of time
    I::Int # Number of units
    U::Int # Periods of day ahead bid
    V::Int # Periods of day ahead clear
    D::Int # Number of days 
    T::Int # Number of periods of time in the horizon
    Kᵦ::Int # Number of prices in the real time curve
    Kᵧ::Int # Number of prices in the day ahead curve
    Kᵪ::Int # Number of inflow scenarios
end

"""Contains the cache data"""
@kwdef mutable struct Cache
    problem_info::Dict{Int,ProblemInfo}
    acceptance_real_time::Array{Bool,4}
    acceptance_day_ahead::Array{Bool,5}
end

"""Contains the storages and generators data"""
@kwdef mutable struct Data
    volume_max::Vector{Float64} # Storage max capacity
    volume_min::Vector{Float64} # Storage min capacity
    volume_initial::Vector{Float64} # Storage inicial condition
    ramp_up::Vector{Float64} # ramp up generation (optional)
    ramp_down::Vector{Float64} # ramp down generation (optional)
    generation_initial::Vector{Float64} # initial generation (optional)
    names::Vector{String} # Storage names (optional)
end

"""Contains all outputs"""
@kwdef mutable struct Output
    objective::Array{Float64,1}
    volume::Array{Float64,3}
    real_time_bid::Array{Float64,4}
    day_ahead_bid::Array{Float64,5}
    day_ahead_clear::Array{Float64,4}
    inflow::Array{Float64,3}
    generation::Array{Float64,3}
    spillage::Array{Float64,3}
end

"""Contains all the problem description"""
@kwdef mutable struct Problem
    options::Options
    numbers::Numbers
    data::Data
    random::RandomVariables
    flags::Flags
    cache::Cache
    output::Output
    model::Union{SDDP.PolicyGraph,Nothing} = nothing
end
