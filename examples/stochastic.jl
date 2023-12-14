using OptimalEnergyBid, HiGHS

prb = create_problem(joinpath(@__DIR__, "cases", "stochastic.json"))
set_optimizer!(prb, HiGHS.Optimizer)
build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")

for t in 1:(prb.numbers.duration), i in 1:(prb.numbers.units)
    prb.random.prices_real_time[t][i] = [1.1, 1.5]
    prb.data.prices_real_time_curve[t][i] = [1.1, 1.5]
end

build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")

for t in 1:(prb.numbers.duration), n in 1:2
    prb.random.inflow[t][n] = [[0.6, 0.3], [0.3, 0.6]]
    prb.random.inflow_probability[t][n] = [0.5, 0.5]
end

for i in 1:(prb.numbers.units)
    prb.random.prices_real_time[3][i] = [1.5, 5.0]
    prb.data.prices_real_time_curve[3][i] = [1.5, 5.0]
end

build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")
