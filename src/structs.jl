struct ProblemInfo
    problem_type::ProblemType
    t::Int
    k::Int
end

@kwdef mutable struct Options
    optimizer::Union{DataType,Nothing} = nothing
end

@kwdef mutable struct RandomVariables
    πᵦ::Array{Float64,3} # Prices of real time (k,i,t)
    ωᵦ::Array{Float64,2} # Probabilities of real time (k,t)
    πᵧ::Array{Float64,4} # Prices of day ahead (k,i,t,n)
    ωᵧ::Array{Float64,2} # Probabilities of day ahead (k,t)
    πᵪ::Array{Float64,3} # Inflow values (j,i,t)
    ωᵪ::Array{Float64,2} # Probabilities of inflow (j,t)
end

@kwdef mutable struct Numbers
    N::Int # Number of periods of time per day
    n₀::Int # First period of time
    I::Int # Number of units
    U::Int # Periods of day ahead bid
    V::Int # Periods of day ahead commit
    T::Int # Number of periods of time in the horizon
    Kᵦ::Int # Number of prices in the real time curve
    Kᵧ::Int # Number of prices in the day ahead curve
    Kᵪ::Int # Number of inflow scenarios
end

@kwdef mutable struct Cache
    problem_type::Dict{Int,ProblemInfo}
    acceptance_real_time::Array{Bool,4}
    acceptance_day_ahead::Array{Bool,5}
end

@kwdef mutable struct Data
    V_max::Vector{Float64} # Storage max capacity
    V_min::Vector{Float64} # Storage min capacity
    V_0::Vector{Float64} # Storage inicial condition
end

@kwdef mutable struct Problem
    options::Options
    random_variables::RandomVariables
    numbers::Numbers
    cache::Cache
    data::Data
    model::Union{SDDP.PolicyGraph,Nothing} = nothing
end
