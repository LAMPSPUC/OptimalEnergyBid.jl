"""Plots all output"""
function plot_all(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)
    _plot_volumes(prb, s, folder)
    _plot_spillages(prb, s, folder)
    _plot_generations(prb, s, folder)
    _plot_inflows(prb, s, folder)
    _plot_real_time_bids(prb, s, folder)
    _plot_day_ahead_clears(prb, s, folder)
    _plot_day_ahead_bids(prb, s, folder)
    return nothing
end

"""Outpus enum"""
@enumx OutputType begin
    Volume
    Spillage
    Generation
    Inflow
    RealTimeBid
    DayAheadClear
    DayAheadBid
end

"""Plot the output"""
function plot_output(
    prb::Problem, type::OutputType.T, s::Int, folder::Union{String,Nothing}=nothing
)
    @match type begin
        $(OutputType.Volume) => _plot_volumes(prb, s, folder)
        $(OutputType.Spillage) => _plot_spillages(prb, s, folder)
        $(OutputType.Generation) => _plot_generations(prb, s, folder)
        $(OutputType.Inflow) => _plot_inflows(prb, s, folder)
        $(OutputType.RealTimeBid) => _plot_real_time_bids(prb, s, folder)
        $(OutputType.DayAheadClear) => _plot_day_ahead_clears(prb, s, folder)
        $(OutputType.DayAheadBid) => _plot_day_ahead_bids(prb, s, folder)
    end
end

"""Plots the day ahead clear output"""
function _plot_day_ahead_bids(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)
    day_ahead_bid = prb.output.day_ahead_bid[:, :, :, :, s]

    for d in 1:(prb.numbers.D), n in 1:(prb.numbers.N), i in 1:(prb.numbers.I)
        prices = prb.random_variables.πᵧ[:, i, n, d]
        offer = day_ahead_bid[:, i, n, d]
        perm = sortperm(prices)
        prices = prices[perm]
        offer = offer[perm]
        for k in 1:(prb.numbers.Kᵧ - 1)
            offer[k + 1] += offer[k]
        end
        plot(
            append!([0.0], offer),
            append!([prices[1]], prices);
            seriestype=:steppre,
            title="Day ahead $(prb.data.names[i]) $n $d",
            label=prb.data.names[i],
        )
        plot!(; legend=:outerbottom)
        ylims!(0, 1.1 * maximum(prices))
        xlabel!("Quantity")
        ylabel!("Price")
        if !isnothing(folder)
            savefig(joinpath(folder, "day_ahead_bid_$(prb.data.names[i])_$(n)_$(d).png"))
        end
    end
    return nothing
end

"""Plots the day ahead clear output"""
function _plot_day_ahead_clears(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)
    day_ahead_clear = prb.output.day_ahead_clear[:, :, :, s]

    for d in 1:(prb.numbers.D)
        vectors = [day_ahead_clear[i, :, d] for i in 1:(prb.numbers.I)]
        plot(
            vectors; title="Day Ahead Clear $(d)", label=prb.data.names, legend=:outerbottom
        )
        ylims!(0, 1.1 * maximum(day_ahead_clear))
        xlabel!("Time")
        ylabel!("Power")
        if !isnothing(folder)
            savefig(joinpath(folder, "day_ahead_clear_$d.png"))
        end
    end
    return nothing
end

"""Plots the real time offer output"""
function _plot_real_time_bids(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)
    real_time_bid = prb.output.real_time_bid[:, :, :, s]

    for t in 1:(prb.numbers.T), i in 1:(prb.numbers.I)
        prices = prb.random_variables.πᵦ[:, i, t]
        offer = real_time_bid[:, i, t]
        perm = sortperm(prices)
        prices = prices[perm]
        offer = offer[perm]
        for k in 1:(prb.numbers.Kᵦ - 1)
            offer[k + 1] += offer[k]
        end
        plot(
            append!([0.0], offer),
            append!([prices[1]], prices);
            seriestype=:steppre,
            title="Real time $(prb.data.names[i]) $t",
            label=prb.data.names[i],
        )
        plot!(; legend=:outerbottom)
        ylims!(0, 1.1 * maximum(prices))
        xlabel!("Quantity")
        ylabel!("Price")
        if !isnothing(folder)
            savefig(joinpath(folder, "real_time_bid_$(prb.data.names[i])_$t.png"))
        end
    end
    return nothing
end

"""Plots the volume output"""
function _plot_volumes(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)
    volume = prb.output.volume[:, :, s]
    vectors = [volume[i, :] for i in 1:(prb.numbers.I)]
    p = plot(vectors; title="Volumes", label=prb.data.names, legend=:outerbottom)
    ylims!(0, 1.1 * maximum(volume))
    xlabel!("Time")
    ylabel!("Volume")
    if !isnothing(folder)
        savefig(joinpath(folder, "volume.png"))
    end
    return p
end

"""Plots the spillage output"""
function _plot_spillages(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)
    spillage = prb.output.spillage[:, :, s]
    vectors = [spillage[i, :] for i in 1:(prb.numbers.I)]
    p = plot(vectors; title="Spillages", label=prb.data.names, legend=:outerbottom)
    ylims!(0, 1.1 * maximum(spillage))
    xlabel!("Time")
    ylabel!("Spillage")
    if !isnothing(folder)
        savefig(joinpath(folder, "spillage.png"))
    end
    return p
end

"""Plots the generation output"""
function _plot_generations(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)
    generation = prb.output.generation[:, :, s]
    vectors = [generation[i, :] for i in 1:(prb.numbers.I)]
    p = plot(vectors; title="Generations", label=prb.data.names, legend=:outerbottom)
    ylims!(0, 1.1 * maximum(generation))
    xlabel!("Time")
    ylabel!("Generation")
    if !isnothing(folder)
        savefig(joinpath(folder, "generation.png"))
    end
    return p
end

"""Plots the inflow output"""
function _plot_inflows(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)
    inflow = prb.output.inflow[:, :, s]
    vectors = [inflow[i, :] for i in 1:(prb.numbers.I)]
    p = plot(vectors; title="Inflows", label=prb.data.names, legend=:outerbottom)
    ylims!(0, 1.1 * maximum(inflow))
    xlabel!("Time")
    ylabel!("Inflow")
    if !isnothing(folder)
        savefig(joinpath(folder, "inflow.png"))
    end
    return p
end
