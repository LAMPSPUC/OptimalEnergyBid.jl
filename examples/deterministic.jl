using OptimalEnergyBid, HiGHS

prb = create_problem(joinpath(@__DIR__, "cases", "deterministic.json"))
set_optimizer!(prb, HiGHS.Optimizer)
build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")

for i in 1:(prb.numbers.I)
    prb.random.πᵦ[3][i][1] = 2.5
end

build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")

for i in 1:(prb.numbers.I)
    prb.random.πᵧ[1][2][i][1] = 3.0
end

build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")

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
plot_all(prb, 1, "")
