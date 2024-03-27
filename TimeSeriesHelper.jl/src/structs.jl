"""Contains all historical data"""
Base.@kwdef mutable struct History
    prices_real_time::Vector{Vector{Float64}} = [] # Prices of real time t,i
    prices_day_ahead::Vector{Vector{Float64}} = [] # Prices of day ahead t,i
    inflow::Vector{Vector{Float64}} = [] # Inflow values t,i
end