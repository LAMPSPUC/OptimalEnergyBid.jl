prb1 = Problem()

numbers = prb1.numbers
random = prb1.random_variables
data = prb1.data
options = prb1.options

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
numbers.Kᵪ = 1
numbers.U = 1
numbers.V = 1

data.volume_max = ones(1)
data.volume_min = zeros(1)
data.volume_initial = zeros(1)

prb2 = create_problem(joinpath(dirname(dirname(@__FILE__)), "cases", "toy_case.json"))

@test random.πᵦ == prb2.random_variables.πᵦ
@test random.ωᵦ == prb2.random_variables.ωᵦ
@test random.πᵧ == prb2.random_variables.πᵧ
@test random.ωᵧ == prb2.random_variables.ωᵧ
@test random.πᵪ == prb2.random_variables.πᵪ
@test random.ωᵪ == prb2.random_variables.ωᵪ

@test numbers.N == prb2.numbers.N
@test numbers.n₀ == prb2.numbers.n₀
@test numbers.I == prb2.numbers.I
@test numbers.T == prb2.numbers.T
@test numbers.Kᵦ == prb2.numbers.Kᵦ
@test numbers.Kᵧ == prb2.numbers.Kᵧ
@test numbers.Kᵪ == prb2.numbers.Kᵪ
@test numbers.U == prb2.numbers.U
@test numbers.V == prb2.numbers.V

@test data.volume_max == prb2.data.volume_max
@test data.volume_min == prb2.data.volume_min
@test data.volume_initial == prb2.data.volume_initial
