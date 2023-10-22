function train!(prb::Problem; kwargs...)
    return SDDP.train(prb.model; kwargs...)
end
