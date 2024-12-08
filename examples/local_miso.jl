using OptimalEnergyBid
using TimeSeriesHelper
using HiGHS

directory = "C:\\Users\\thiag\\Documents\\Data\\";
start = 20240810;
stop = 20240823;
T = 24 # hours per day
D = 48 # duration in hours
S = 8 # number of scenarios
P = 3 # number of inflow scenarios per scenarios

day_ahead = TimeSeriesHelper.read_miso_da_lmps(
    directory, start, stop + 1
)

real_time = TimeSeriesHelper.read_miso_rt_lmps(
    directory, start, stop
)

wind = TimeSeriesHelper.read_open_meteo_json(
    directory, "wind_speed_10m", start, stop
)

nodes = ["AECI", "AEP"]

prices_real_time = Vector{Vector{Float64}}()
for i in 1:(stop - start + 1) * T
    push!(prices_real_time, [])
    for node in nodes
        push!(prices_real_time[i], real_time[node][i])
    end
end

prices_day_ahead = Vector{Vector{Float64}}()
for i in 1:(stop - start + 2) * T
    push!(prices_day_ahead, [])
    for node in nodes
        push!(prices_day_ahead[i], day_ahead[node][i])
    end
end

inflow = Vector{Vector{Float64}}()
for i in 1:(stop - start + 1) * T
    push!(inflow, [])
    for key in keys(wind)
        push!(inflow[i], wind[key][i])
    end
end

history = TimeSeriesHelper.History()
history.prices_real_time = prices_real_time
history.prices_day_ahead = prices_day_ahead
history.inflow = inflow

h = TimeSeriesHelper.build_serial_history(history, 336, T)

m, o = TimeSeriesHelper.estimate_hmm(h, S)

matrix = TimeSeriesHelper.build_markov_transition(m, D)

rt, da, inflow = TimeSeriesHelper.build_scenarios(o, D, T, P, 1, 2, 2)

prb = OptimalEnergyBid.Problem()

numbers = prb.numbers
random = prb.random
data = prb.data
options = prb.options

numbers.periods_per_day = T
numbers.first_period = 1
numbers.units = 2
numbers.buses = 2
numbers.duration = D
numbers.real_time_steps = S
numbers.day_ahead_steps = S
numbers.period_of_day_ahead_bid = 12
numbers.period_of_day_ahead_clear = 20
# TODO
numbers.days = 2

random.prices_real_time = rt
random.prices_day_ahead = da
random.inflow = inflow
random.inflow_probability = v = [[[1/P for k in 1:P] for j in 1:S] for i in 1:D]
random.markov_transitions = matrix

data.unit_to_bus = [1, 2]
data.volume_max = ones(2) * 15
data.volume_min = zeros(2)
data.volume_initial = zeros(2)

rt_sorted = deepcopy(rt)
da_sorted = deepcopy(da)

for t in 1:D
    for i in 1:2
        sort!(rt_sorted[t][i])
    end
end

for d in 1:2
    for j in 1:T
        for i in 1:2
            sort!(da_sorted[d][j][i])
        end
    end
end

data.prices_real_time_curve = rt_sorted
data.prices_day_ahead_curve = da_sorted
data.names = ["unit1", "unit2"]

OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.Optimizer, HiGHS.Optimizer)

OptimalEnergyBid.build_model!(prb, true)
OptimalEnergyBid.train!(prb; time_limit=60)
OptimalEnergyBid.simulate!(prb)
OptimalEnergyBid.plot_all(prb, 1, "")
