using OptimalEnergyBid, HiGHS

prb = create_problem(joinpath(@__DIR__, "cases", "stochastic.json"))
set_optimizer!(prb, HiGHS.Optimizer)
build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")

for t in 1:(prb.numbers.T), i in 1:(prb.numbers.I)
    prb.random.πᵦ[t][i] = [1.1, 1.5]
    prb.data.pᵦ[t][i] = [1.1, 1.5]
end

build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")

for t in 1:(prb.numbers.T), n in 1:2
    prb.random.πᵪ[t][n] = [[0.6, 0.3], [0.3, 0.6]]
    prb.random.ωᵪ[t][n] = [0.5, 0.5]
end

for i in 1:(prb.numbers.I)
    prb.random.πᵦ[3][i] = [1.5, 5.0]
    prb.data.pᵦ[3][i] = [1.5, 5.0]
end

build_model!(prb)
train!(prb)
simul = simulate!(prb)
plot_all(prb, 1, "")
