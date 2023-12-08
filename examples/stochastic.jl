using OptimalEnergyBid, HiGHS

prb = create_problem(joinpath(@__DIR__, "cases", "stochastic.json"))
set_optimizer!(prb, HiGHS.Optimizer)
build_model!(prb)
train!(prb)
simul = simulate!(prb)

prb.random.πᵦ[1, :, :] .= 1.1

build_model!(prb)
train!(prb)
simul = simulate!(prb)

prb.random.ωᵪ = [
    0.5 0.5 0.5 0.5 0.5 0.5
    0.5 0.5 0.5 0.5 0.5 0.5
]

prb.random.πᵪ = zeros(2, 2, 6)

prb.random.πᵪ[1, 1, :] .= 0.6
prb.random.πᵪ[1, 2, :] .= 0.3
prb.random.πᵪ[2, 1, :] .= 0.3
prb.random.πᵪ[2, 2, :] .= 0.6

build_model!(prb)
train!(prb)
simul = simulate!(prb)
