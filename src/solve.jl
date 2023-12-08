"""
    train!(prb::Problem;kwargs...) 

Train future cost function using SDDP.

Keyword arguments (same as SDDP.train):
<https://github.com/odow/SDDP.jl/blob/0490bea2c46787e1d4d63a5491ea0106c7fe70cf/src/algorithm.jl#L780-L827>

"""
function train!(prb::Problem; kwargs...)
    return SDDP.train(prb.model; kwargs...)
end

"""
    simulate!(prb::Problem,
        number_replications::Int = 1,
        variables::Vector{Symbol} = Symbol[]
        skip_undefined_variables::Bool = true
        )::Vector{Vector{Dict{Symbol, Any}}}

Simulates using SDDP.

Keyword arguments (same as SDDP.simulate):
<https://github.com/odow/SDDP.jl/blob/0490bea2c46787e1d4d63a5491ea0106c7fe70cf/src/algorithm.jl#L1071-L1124>

"""
function simulate!(
    prb::Problem,
    number_replications::Int=1,
    variables::Vector{Symbol}=variable_list,
    skip_undefined_variables::Bool=true;
    kwargs...,
)::Vector{Vector{Dict{Symbol,Any}}}
    simul = SDDP.simulate(
        prb.model,
        number_replications,
        variables;
        skip_undefined_variables=skip_undefined_variables,
        kwargs...,
    )
    _write_output!(prb, simul)
    return simul
end
