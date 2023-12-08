"""Contains all user options"""
Base.@kwdef mutable struct Options
    optimizer::Union{DataType,Nothing} = nothing
    use_ramp_up::Bool = false
    use_ramp_down::Bool = false
    use_day_ahead_bid_bound::Bool = true
    penalty_ramp_down::Float64 = 0.0
end

"""Contains all flags, evaluated using options"""
Base.@kwdef mutable struct Flags
    generation_as_state::Bool = false
end

"""Contains all random variables"""
Base.@kwdef mutable struct RandomVariables
    πᵦ::Vector{Vector{Vector{Float64}}} = [] # Prices of real time t,i,n
    πᵧ::Vector{Vector{Vector{Vector{Float64}}}} = [] # Prices of day ahead d,j,i,n
    πᵪ::Vector{Vector{Vector{Vector{Float64}}}} = [] # Inflow values t,n,w,i
    ωᵪ::Vector{Vector{Vector{Float64}}} = [] # Probabilities of inflow t,n,w
    P::Vector{Matrix{Float64}} = [] # Markov transition matrices
end

"""Contains all sizes and indices"""
Base.@kwdef mutable struct Numbers
    N::Int = 0 # Number of periods of time per day
    n₀::Int = 0 # First period of time
    I::Int = 0 # Number of units
    U::Int = 0 # Periods of day ahead bid
    V::Int = 0 # Periods of day ahead clear
    D::Int = 0 # Number of days 
    T::Int = 0 # Number of periods of time in the horizon
    Kᵦ::Int = 0 # Number of prices in the real time curve
    Kᵧ::Int = 0 # Number of prices in the day ahead curve
end

"""Contains the cache data"""
Base.@kwdef mutable struct Cache
    acceptance_real_time::Vector{Vector{Matrix{Bool}}} = [] # t,n,i,k
    acceptance_day_ahead::Vector{Vector{Vector{Matrix{Bool}}}} = [] # d,j,n,i,k
end

"""Contains the storages and generators data"""
Base.@kwdef mutable struct Data
    volume_max::Vector{Float64} = Array{Float64}(undef, zeros(Int, 1)...) # Storage max capacity
    volume_min::Vector{Float64} = Array{Float64}(undef, zeros(Int, 1)...) # Storage min capacity
    volume_initial::Vector{Float64} = Array{Float64}(undef, zeros(Int, 1)...) # Storage inicial condition
    pᵦ::Vector{Vector{Vector{Float64}}} = [] # Prices of real time t,i,k
    pᵧ::Vector{Vector{Vector{Vector{Float64}}}} = [] # Prices of day ahead d,j,i,k
    ramp_up::Vector{Float64} = Array{Float64}(undef, zeros(Int, 1)...) # ramp up generation (optional)
    ramp_down::Vector{Float64} = Array{Float64}(undef, zeros(Int, 1)...) # ramp down generation (optional)
    generation_initial::Vector{Float64} = Array{Float64}(undef, zeros(Int, 1)...) # initial generation (optional)
    names::Vector{String} = Array{String}(undef, zeros(Int, 1)...) # Storage names (optional)
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
end

"""Contains all the problem description"""
Base.@kwdef mutable struct Problem
    options::Options = Options()
    numbers::Numbers = Numbers()
    data::Data = Data()
    random::RandomVariables = RandomVariables()
    flags::Flags = Flags()
    cache::Cache = Cache()
    output::Output = Output()
    model::Union{SDDP.PolicyGraph,Nothing} = nothing
end
