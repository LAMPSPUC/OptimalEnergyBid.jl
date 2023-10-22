function simulate(
    prb::Problem, number_replications::Int=1; kwargs...
)::Vector{Vector{Dict{Symbol,Any}}}
    return SDDP.simulate(prb.model, number_replications; kwargs...)
end
