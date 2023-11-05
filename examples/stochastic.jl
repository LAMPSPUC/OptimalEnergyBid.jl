using MaxStorageRevenue, HiGHS

prb = create_problem(joinpath(dirname(dirname(@__FILE__)), "cases", "stochastic.json"))
set_optimizer!(prb, HiGHS.Optimizer)
build_model!(prb)
train!(prb; time_limit=10)
simul = simulate!(prb, 2)

plot_all(prb, 2, "")

prb.random.ωᵪ = [
    0.5 0.5 0.5 0.5 0.5 0.5
    0.5 0.5 0.5 0.5 0.5 0.5
]

build_model!(prb)
train!(prb; time_limit=10)
simul = simulate!(prb, 2)

plot_all(prb, 2, "")
