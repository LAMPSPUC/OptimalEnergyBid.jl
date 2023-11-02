using MaxStorageRevenue, HiGHS

prb = create_problem(joinpath(dirname(dirname(@__FILE__)), "cases", "stochastic_case.json"))
set_optimizer!(prb, HiGHS.Optimizer)
build_model!(prb)
train!(prb)
simul = simulate!(prb, 2)
