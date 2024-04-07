"""Contains all user options"""
Base.@kwdef mutable struct Options
    optimizer::Union{DataType,Nothing} = nothing
    use_ramp_up::Bool = false
    use_ramp_down::Bool = false
    use_day_ahead_bid_bound::Bool = true
    penalty_ramp_down::Float64 = 0.0
    lambda::Float64 = 1.0
    beta::Float64 = 0.0
end

"""Contains all flags, evaluated using options"""
Base.@kwdef mutable struct Flags
    generation_as_state::Bool = false
end

"""Contains all random variables"""
Base.@kwdef mutable struct Random
    prices_real_time::Vector{Vector{Vector{Float64}}} = [] # Prices of real time t,b,n
    prices_day_ahead::Vector{Vector{Vector{Vector{Float64}}}} = [] # Prices of day ahead d,j,b,n
    inflow::Vector{Vector{Vector{Vector{Float64}}}} = [] # Inflow values t,n,w,i
    inflow_probability::Vector{Vector{Vector{Float64}}} = [] # Probabilities of inflow t,n,w
    markov_transitions::Vector{Matrix{Float64}} = [] # Markov transition matrices
end

"""Contains all sizes and indices"""
Base.@kwdef mutable struct Numbers
    periods_per_day::Int = 0 # Number of periods of time per day
    first_period::Int = 0 # First period of time
    units::Int = 0 # Number of units
    buses::Int = 0 # Number of buses
    period_of_day_ahead_bid::Int = 0 # Periods of day ahead bid
    period_of_day_ahead_clear::Int = 0 # Periods of day ahead clear
    days::Int = 0 # Number of days 
    duration::Int = 0 # Number of periods of time in the horizon
    real_tume_steps::Int = 0 # Number of prices in the real time curve
    day_ahead_steps::Int = 0 # Number of prices in the day ahead curve
end

"""Contains the cache data"""
Base.@kwdef mutable struct Cache
    acceptance_real_time::Vector{Vector{Matrix{Bool}}} = [] # t,n,i,k
    acceptance_day_ahead::Vector{Vector{Vector{Matrix{Bool}}}} = [] # d,j,n,i,k
end

"""Contains the storages and generators data"""
Base.@kwdef mutable struct Data
    volume_max::Vector{Float64} = [] # Storage max capacity
    volume_min::Vector{Float64} = [] # Storage min capacity
    volume_initial::Vector{Float64} = [] # Storage inicial condition
    prices_real_time_curve::Vector{Vector{Vector{Float64}}} = [] # Prices of real time t,i,k
    prices_day_ahead_curve::Vector{Vector{Vector{Vector{Float64}}}} = [] # Prices of day ahead d,j,i,k
    ramp_up::Vector{Float64} = [] # ramp up generation (optional)
    ramp_down::Vector{Float64} = [] # ramp down generation (optional)
    generation_initial::Vector{Float64} = [] # initial generation (optional)
    unit_to_bus::Vector{Int32} = [] # Mapping units to buses
    names::Vector{String} = [] # Storage names (optional)
end

"""Contains all outputs"""
Base.@kwdef mutable struct Output
    objective::Array{Float64,1} = Array{Float64}(undef, zeros(Int, 1)...)
    volume::Array{Float64,3} = Array{Float64}(undef, zeros(Int, 3)...)
    real_time_bid::Array{Float64,4} = Array{Float64}(undef, zeros(Int, 4)...)
    day_ahead_bid::Array{Float64,5} = Array{Float64}(undef, zeros(Int, 5)...)
    day_ahead_clear::Array{Float64,4} = Array{Float64}(undef, zeros(Int, 4)...)
    inflow::Array{Float64,3} = Array{Float64}(undef, zeros(Int, 3)...)
    generation::Array{Float64,3} = Array{Float64}(undef, zeros(Int, 3)...)
    spillage::Array{Float64,3} = Array{Float64}(undef, zeros(Int, 3)...)
    ramp_down_violation::Array{Float64,3} = Array{Float64}(undef, zeros(Int, 3)...)
end

"""Contains all the problem description"""
Base.@kwdef mutable struct Problem
    options::Options = Options()
    numbers::Numbers = Numbers()
    data::Data = Data()
    random::Random = Random()
    flags::Flags = Flags()
    cache::Cache = Cache()
    output::Output = Output()
    model::Union{SDDP.PolicyGraph,Nothing} = nothing
end
