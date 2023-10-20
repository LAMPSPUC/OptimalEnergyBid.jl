@kwdef mutable struct Options
end

@kwdef mutable struct RandomVariables
    πᵦ::Array{Float64,3} # Prices of real time (k,i,t)
    ωᵦ::Array{Float64,2} # Probabilities of real time (k,t)
    πᵧ::Array{Float64,3} # Prices of day ahead (k,i,t)
    ωᵧ::Array{Float64,2} # Probabilities of day ahead (k,t)
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
end

@kwdef mutable struct Cache
    problem_type::Dict{Int, ProblemType}
end

@kwdef mutable struct Problem
    options::Options
    random_variables::RandomVariables
    numbers::Numbers
    cache::Cache
end