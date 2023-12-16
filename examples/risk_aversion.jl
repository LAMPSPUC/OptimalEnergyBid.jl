using OptimalEnergyBid, HiGHS

prb = OptimalEnergyBid.create_problem(joinpath(@__DIR__, "cases", "stochastic.json"))
OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.Optimizer, HiGHS.Optimizer)
for t in 1:(prb.numbers.duration), i in 1:(prb.numbers.units)
    prb.random.prices_real_time[t][i] = [1.5 - t * 0.1, 2.0 + 2.5^t]
    prb.data.prices_real_time_curve[t][i] = [1.5 - t * 0.1, 2.0 + 2.5^t]
end
prb.data.volume_max = [100.0, 100.0]
OptimalEnergyBid.build_model!(prb)
OptimalEnergyBid.train!(prb)
OptimalEnergyBid.simulate!(prb)
OptimalEnergyBid.plot_all(prb, 1, "")

OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.Lambda, 0.0)
OptimalEnergyBid.build_model!(prb)
OptimalEnergyBid.train!(prb)
OptimalEnergyBid.simulate!(prb)
OptimalEnergyBid.plot_all(prb, 1, "")
