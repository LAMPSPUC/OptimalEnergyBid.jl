function simulate!(
    prb::Problem, number_replications::Int=1, variables::Vector{Symbol} = variable_list, skip_undefined_variables::Bool = true; kwargs...
)::Vector{Vector{Dict{Symbol,Any}}}
    simul = SDDP.simulate(prb.model, number_replications, variables; skip_undefined_variables=skip_undefined_variables, kwargs...)
    write_output!(prb, simul)
    return simul
end
