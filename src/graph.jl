"""Plots all output"""
function plot_all(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)::Nothing
    plot_volumes(prb, s, folder)
    plot_spillages(prb, s, folder)
    plot_generations(prb, s, folder)
    plot_inflows(prb, s, folder)
    plot_real_time_bids(prb, s, folder)
    plot_day_ahead_clears(prb, s, folder)
    plot_day_ahead_bids(prb, s, folder)
    return nothing
end

"""Plots the day ahead clear output"""
function plot_day_ahead_bids(
    prb::Problem, s::Int, folder::Union{String,Nothing}=nothing
)::Nothing
    day_ahead_bid = prb.output.day_ahead_bid[:, :, :, :, s]

    for d in 1:(prb.numbers.days),
        n in 1:(prb.numbers.periods_per_day),
        i in 1:(prb.numbers.units)

        prices = prb.data.prices_day_ahead_curve[d][n][i]
        offer = day_ahead_bid[:, i, n, d]
        for k in 1:(prb.numbers.day_ahead_steps - 1)
            offer[k + 1] += offer[k]
        end
        plot(
            append!([0.0], offer),
            append!([prices[1]], prices);
            seriestype=:steppre,
            title="Day ahead $(prb.data.names[i]) hour: $n day: $d",
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
function plot_day_ahead_clears(
    prb::Problem, s::Int, folder::Union{String,Nothing}=nothing
)::Nothing
    day_ahead_clear = prb.output.day_ahead_clear[:, :, :, s]

    for d in 1:(prb.numbers.days)
        vectors = [day_ahead_clear[i, :, d] for i in 1:(prb.numbers.units)]
        plot(
            vectors;
            title="Day Ahead Clear day: $(d)",
            label=reshape(
                reshape(prb.data.names, 1, prb.numbers.units), 1, prb.numbers.units
            ),
            legend=:outerbottom,
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
function plot_real_time_bids(
    prb::Problem, s::Int, folder::Union{String,Nothing}=nothing
)::Nothing
    real_time_bid = prb.output.real_time_bid[:, :, :, s]

    for t in 1:(prb.numbers.duration), i in 1:(prb.numbers.units)
        prices = prb.data.prices_real_time_curve[t][i]
        offer = real_time_bid[:, i, t]
        for k in 1:(prb.numbers.real_tume_steps - 1)
            offer[k + 1] += offer[k]
        end
        plot(
            append!([0.0], offer),
            append!([prices[1]], prices);
            seriestype=:steppre,
            title="Real time $(prb.data.names[i]) time: $t",
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
function plot_volumes(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)::Nothing
    volume = prb.output.volume[:, :, s]
    vectors = [volume[i, :] for i in 1:(prb.numbers.units)]
    plot(
        vectors;
        title="Volumes",
        label=reshape(prb.data.names, 1, prb.numbers.units),
        legend=:outerbottom,
    )
    ylims!(0, 1.1 * maximum(volume))
    xlabel!("Time")
    ylabel!("Volume")
    if !isnothing(folder)
        savefig(joinpath(folder, "volume.png"))
    end
    return nothing
end

"""Plots the spillage output"""
function plot_spillages(
    prb::Problem, s::Int, folder::Union{String,Nothing}=nothing
)::Nothing
    spillage = prb.output.spillage[:, :, s]
    vectors = [spillage[i, :] for i in 1:(prb.numbers.units)]
    plot(
        vectors;
        title="Spillages",
        label=reshape(prb.data.names, 1, prb.numbers.units),
        legend=:outerbottom,
    )
    ylims!(0, 1.1 * maximum(spillage))
    xlabel!("Time")
    ylabel!("Spillage")
    if !isnothing(folder)
        savefig(joinpath(folder, "spillage.png"))
    end
    return nothing
end

"""Plots the generation output"""
function plot_generations(
    prb::Problem, s::Int, folder::Union{String,Nothing}=nothing
)::Nothing
    generation = prb.output.generation[:, :, s]
    vectors = [generation[i, :] for i in 1:(prb.numbers.units)]
    plot(
        vectors;
        title="Generations",
        label=reshape(prb.data.names, 1, prb.numbers.units),
        legend=:outerbottom,
    )
    ylims!(0, 1.1 * maximum(generation))
    xlabel!("Time")
    ylabel!("Generation")
    if !isnothing(folder)
        savefig(joinpath(folder, "generation.png"))
    end
    return nothing
end

"""Plots the inflow output"""
function plot_inflows(prb::Problem, s::Int, folder::Union{String,Nothing}=nothing)::Nothing
    inflow = prb.output.inflow[:, :, s]
    vectors = [inflow[i, :] for i in 1:(prb.numbers.units)]
    plot(
        vectors;
        title="Inflows",
        label=reshape(prb.data.names, 1, prb.numbers.units),
        legend=:outerbottom,
    )
    ylims!(0, 1.1 * maximum(inflow))
    xlabel!("Time")
    ylabel!("Inflow")
    if !isnothing(folder)
        savefig(joinpath(folder, "inflow.png"))
    end
    return nothing
end
