using MaxStorageRevenue, HiGHS

prb = create_problem(joinpath(@__DIR__, "cases", "stochastic.json"))
set_optimizer!(prb, HiGHS.Optimizer)
build_model!(prb)
train!(prb)
simul = simulate!(prb, 1)
plot_all(prb, 1, "")

prb.random.πᵦ[1,:,:] .= 1.1

build_model!(prb)
train!(prb)
simul = simulate!(prb, 1)
plot_all(prb, 1, "")

prb.random.ωᵪ = [
0.5 0.5 0.5 0.5 0.5 0.5
0.5 0.5 0.5 0.5 0.5 0.5
]

prb.random.πᵪ = zeros(2,2,6)

prb.random.πᵪ[1,1,:] .= 0.6
prb.random.πᵪ[1,2,:] .= 0.3
prb.random.πᵪ[2,1,:] .= 0.3
prb.random.πᵪ[2,2,:] .= 0.6

build_model!(prb)
train!(prb)
simul = simulate!(prb, 5)

plot_all(prb, 1, "")
plot_all(prb, 2, "")
plot_all(prb, 3, "")
plot_all(prb, 4, "")
plot_all(prb, 5, "")
