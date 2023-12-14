prb = OptimalEnergyBid.create_problem(joinpath(dirname(@__DIR__), "cases", "toy.json"))

OptimalEnergyBid.set_parameter!(prb, OptimalEnergyBid.Parameter.Optimizer, HiGHS.Optimizer)

OptimalEnergyBid.build_model!(prb, true)
OptimalEnergyBid.train!(prb)
OptimalEnergyBid.simulate!(prb)
