using OptimalEnergyBid
using TimeSeriesHelper
using ElectricityMarketData
using HiGHS
using Dates

start = DateTime(2024, 12, 1, 0, 0);
stop = DateTime(2025, 1, 1, 0, 0);

D = 24; # hours per day
T = 24 * 31; # duration in hours
S = 5; # number of scenarios
P = 2; # number of inflow scenarios per scenarios
U = 12; # day ahead bid hour
V = 17; # day ahead clear hour
map = [1, 2, 3];
VMAX = 15;

nodes = ["NIPS.NIPS", "CIN.DEI.AZ", "CIN.GIBSON.5"];
coordinates = [("41.525275", "-87.113273"), ("40.925566", "-86.246378"), ("38.498330", "-87.445701")];

I = length(coordinates);
K = length(nodes);

######################################################################################

market = ElectricityMarketData.MisoMarket();

# prices real time
df_real_time = ElectricityMarketData.get_real_time_lmp(market, start, stop);
real_time_filter = [];
for node in nodes
    push!(real_time_filter, filter(row -> row.Node == node, df_real_time))
end
prices_real_time = Vector{Vector{Float64}}();
for i in 1:size(real_time_filter[1])[1]
    push!(prices_real_time, [])
    for j in 1:K
        push!(prices_real_time[i], real_time_filter[j][i, :LMP])
    end
end

# prices day ahead
df_day_ahead = ElectricityMarketData.get_day_ahead_lmp(market, start, stop);
day_ahead_filter = [];
for node in nodes
    push!(day_ahead_filter, filter(row -> row.Node == node, df_day_ahead))
end
prices_day_ahead = Vector{Vector{Float64}}();
for i in 1:size(day_ahead_filter[1])[1]
    push!(prices_day_ahead, [])
    for j in 1:K
        push!(prices_day_ahead[i], day_ahead_filter[j][i, :LMP])
    end
end

# inflow
wind = TimeSeriesHelper.read_open_meteo_json("wind_speed_10m", start, stop, coordinates);
inflow = Vector{Vector{Float64}}();
for i in 1:(length(wind[coordinates[1]]))
    push!(inflow, [])
    for key in keys(wind)
        push!(inflow[i], wind[key][i])
    end
end

history = TimeSeriesHelper.History();
history.prices_real_time = prices_real_time;
history.prices_day_ahead = prices_day_ahead;
history.inflow = inflow;

h = TimeSeriesHelper.build_serial_history(history, T, D);

m, o = TimeSeriesHelper.estimate_hmm(h, S);

matrix = TimeSeriesHelper.build_markov_transition(m, T);

rt, da, inflow = TimeSeriesHelper.build_scenarios(o, T, D, P, U, K, I);

prb = OptimalEnergyBid.Problem();

numbers = prb.numbers;
random = prb.random;
data = prb.data;
options = prb.options;

numbers.periods_per_day = D;
numbers.first_period = 1;
numbers.units = I;
numbers.buses = K;
numbers.duration = T;
numbers.real_time_steps = S;
numbers.day_ahead_steps = S;
numbers.period_of_day_ahead_bid = U;
numbers.period_of_day_ahead_clear = V;

random.prices_real_time = rt;
random.prices_day_ahead = da;
random.inflow = inflow;
random.inflow_probability = v = [[[1 / P for k in 1:P] for j in 1:S] for i in 1:T];
random.markov_transitions = matrix;

data.unit_to_bus = map;
data.volume_max = ones(I) * VMAX;
data.volume_min = zeros(I);
data.volume_initial = zeros(I);

rt_sorted = deepcopy(rt);
da_sorted = deepcopy(da);

for t in 1:T
    for i in 1:I
        sort!(rt_sorted[t][i])
    end
end

for d in 1:(T ÷ D)
    for j in 1:D
        for i in 1:I
            sort!(da_sorted[d][j][i])
        end
    end
end

data.prices_real_time_curve = rt_sorted;
data.prices_day_ahead_curve = da_sorted;
data.names = ["unit1", "unit2", "unit3"];

OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.Optimizer, HiGHS.Optimizer);
OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.Lambda, 0.05);
OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.Beta, 0.05);

OptimalEnergyBid.build_model!(prb, false);
OptimalEnergyBid.train!(prb; time_limit=300);
#OptimalEnergyBid.simulate!(prb);
#OptimalEnergyBid.plot_all(prb, 1, "");
