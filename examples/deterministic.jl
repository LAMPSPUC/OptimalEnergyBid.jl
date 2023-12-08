using OptimalEnergyBid, HiGHS

prb = create_problem(joinpath(@__DIR__, "cases", "deterministic.json"))
set_optimizer!(prb, HiGHS.Optimizer)
build_model!(prb)
train!(prb)
simul = simulate!(prb)

prb.random.πᵦ[:, :, 2] .+= 0.5
build_model!(prb)
train!(prb)
simul = simulate!(prb)

prb.random.πᵧ[:, :, 1, 1] .+= 1.0
build_model!(prb)
train!(prb)
simul = simulate!(prb)

prb = create_problem(joinpath(@__DIR__, "cases", "deterministic.json"))
set_optimizer!(prb, HiGHS.Optimizer)

set_bool_parameter!(prb, ParameterBool.UseRampUp, true)
set_bool_parameter!(prb, ParameterBool.UseRampDown, true)
set_float_parameter!(prb, ParameterFloat.PenaltyRampDown, 100.0)

prb.data.ramp_up = [0.1, 0.1]
prb.data.ramp_down = [0.1, 0.1]
prb.data.generation_initial = [0.1, 0.1]

build_model!(prb)
train!(prb)
simul = simulate!(prb)
