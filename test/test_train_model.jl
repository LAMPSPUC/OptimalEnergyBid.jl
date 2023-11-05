prb = Problem()

numbers = prb.numbers
random = prb.random
data = prb.data
options = prb.options

values_beta = zeros(1, 1, 1)
values_gamma = zeros(1, 1, 1, 1)
probabilities = zeros(1, 1)
probabilities[:, :] .= 1.0
values_beta[:, :, :] .= 10.0
values_gamma[:, :, :, :] .= 9.0
random.πᵦ = values_beta
random.ωᵦ = probabilities
random.πᵧ = values_gamma
random.ωᵧ = probabilities

values_chi = zeros(1, 1, 1)
values_chi[:, :, :] .= 1.0
random.πᵪ = values_chi
random.ωᵪ = probabilities

numbers.N = 1
numbers.n₀ = 1
numbers.I = 1
numbers.T = 1
numbers.Kᵦ = 1
numbers.Kᵧ = 1
numbers.U = 1
numbers.V = 1
numbers.D = 1

data.volume_max = ones(1)
data.volume_min = zeros(1)
data.volume_initial = zeros(1)

set_optimizer!(prb, HiGHS.Optimizer)

build_model!(prb)
train!(prb)
simulate!(prb)
