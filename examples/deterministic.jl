using MaxStorageRevenue, HiGHS

prb = create_problem(
    joinpath(dirname(dirname(@__FILE__)), "cases", "deterministc_case.json")
)
prb.options.optimizer = HiGHS.Optimizer
build_model!(prb)
train!(prb)
simul = simulate!(prb, 1)
plot_all(prb, 1, "")

prb.random_variables.πᵦ[:,:,2] .+= 0.5
build_model!(prb)
train!(prb)
simul = simulate!(prb, 1)
plot_all(prb, 1, "")

prb.random_variables.πᵧ[:,:,1,1] .+= 1.0
build_model!(prb)
train!(prb)
simul = simulate!(prb, 1)
plot_all(prb, 1, "")
