using MaxStorageRevenue, HiGHS

prb = create_problem(joinpath(dirname(dirname(@__FILE__)), "cases", "deterministc_case.json"))
prb.options.optimizer = HiGHS.Optimizer
build_model!(prb)
train!(prb)
simul = simulate!(prb, 2)