using OptimalEnergyBid, HiGHS

prb = OptimalEnergyBid.create_problem(joinpath(@__DIR__, "cases", "deterministic.json"))
OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.Optimizer, HiGHS.Optimizer)
OptimalEnergyBid.build_model!(prb)
OptimalEnergyBid.train!(prb)
simul = OptimalEnergyBid.simulate!(prb)
OptimalEnergyBid.plot_all(prb, 1, "")

for i in 1:(prb.numbers.units)
    prb.random.prices_real_time[3][i][1] = 2.5
end

OptimalEnergyBid.build_model!(prb)
OptimalEnergyBid.train!(prb)
OptimalEnergyBid.simulate!(prb)
OptimalEnergyBid.plot_all(prb, 1, "")

for i in 1:(prb.numbers.units)
    prb.random.prices_day_ahead[1][2][i][1] = 3.0
end

OptimalEnergyBid.build_model!(prb)
OptimalEnergyBid.train!(prb)
OptimalEnergyBid.simulate!(prb)
OptimalEnergyBid.plot_all(prb, 1, "")

prb = OptimalEnergyBid.create_problem(joinpath(@__DIR__, "cases", "deterministic.json"))
OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.Optimizer, HiGHS.Optimizer)
OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.UseRampUp, true)
OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.UseRampDown, true)
OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.PenaltyRampDown, 100.0)

prb.data.ramp_up = [0.1, 0.1]
prb.data.ramp_down = [0.1, 0.1]
prb.data.generation_initial = [0.1, 0.1]

OptimalEnergyBid.build_model!(prb)
OptimalEnergyBid.train!(prb)
OptimalEnergyBid.simulate!(prb)
OptimalEnergyBid.plot_all(prb, 1, "")
