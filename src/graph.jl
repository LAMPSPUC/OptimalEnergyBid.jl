function plot_volumes(prb::Problem, s::Int, path::String=nothing)
    volume = prb.output.volume[:,:,s]
    vectors = [volume[i,:] for i in 1:prb.numbers.I]
    p = plot(vectors, title="Volumes")
    plot!(legend=:outerbottom)
    xlabel!("Time")
    ylabel!("Volume")
    if !isnothing(path)
        savefig(path) 
    end
    return p
end

function plot_spillages(prb::Problem, s::Int, path::String=nothing)
    spillage = prb.output.spillage[:,:,s]
    vectors = [spillage[i,:] for i in 1:prb.numbers.I]
    p = plot(vectors, title="Spillages")
    plot!(legend=:outerbottom)
    xlabel!("Time")
    ylabel!("Spillage")
    if !isnothing(path)
        savefig(path) 
    end
    return p
end

function plot_generations(prb::Problem, s::Int, path::String=nothing)
    generation = prb.output.generation[:,:,s]
    vectors = [generation[i,:] for i in 1:prb.numbers.I]
    p = plot(vectors, title="Generations")
    plot!(legend=:outerbottom)
    xlabel!("Time")
    ylabel!("Generation")
    if !isnothing(path)
        savefig(path) 
    end
    return p
end

function plot_inflows(prb::Problem, s::Int, path::String=nothing)
    inflow = prb.output.inflow[:,:,s]
    vectors = [inflow[i,:] for i in 1:prb.numbers.I]
    p = plot(vectors, title="Inflows")
    plot!(legend=:outerbottom)
    xlabel!("Time")
    ylabel!("Inflow")
    if !isnothing(path)
        savefig(path) 
    end
    return p
end