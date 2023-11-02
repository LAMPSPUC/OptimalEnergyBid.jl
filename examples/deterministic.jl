using MaxStorageRevenue, HiGHS

prb = create_problem(
    joinpath(dirname(dirname(@__FILE__)), "cases", "deterministc_case.json")
)
set_optimizer!(prb, HiGHS.Optimizer)
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

set_use_ramp_up!(prb, true)
set_use_ramp_down!(prb, true)
set_penalty_ramp_up!(prb, 100.0)
set_penalty_ramp_down!(prb, 100.0)

prb.data.ramp_up = [0.1, 0.1]
prb.data.ramp_down = [0.1, 0.1]
prb.data.generation_initial = [0.1, 0.1]
