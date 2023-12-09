using OptimalEnergyBid, HiGHS

prb = create_problem(joinpath(@__DIR__, "cases", "stochastic.json"))
set_optimizer!(prb, HiGHS.Optimizer)
build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")

for t in 1:(prb.numbers.T), i in 1:(prb.numbers.I)
    prb.random.πᵦ[t][i] = [1.1, 1.5]
end

build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")

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
