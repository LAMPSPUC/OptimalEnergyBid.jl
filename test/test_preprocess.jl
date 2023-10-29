prb = Problem()

numbers = prb.numbers
random = prb.random_variables
data = prb.data
options = prb.options

values_beta = zeros(2, 1, 2)
values_gamma = zeros(2, 1, 2, 1)
probabilities = zeros(2, 2)
probabilities[:, :] .= 0.5
values_beta[1, :, 1] .= 10.0
values_beta[1, :, 2] .= 9.0
values_beta[2, :, 1] .= 9.0
values_beta[2, :, 2] .= 10.0
values_gamma[1, :, 1, :] .= 10.0
values_gamma[1, :, 2, :] .= 9.0
values_gamma[2, :, 1, :] .= 9.0
values_gamma[2, :, 2, :] .= 10.0
random.πᵦ = values_beta
random.ωᵦ = probabilities
random.πᵧ = values_gamma
random.ωᵧ = probabilities
random.πᵪ = values_beta
random.ωᵪ = probabilities

numbers.N = 2
numbers.n₀ = 2
numbers.I = 1
numbers.T = 2
numbers.Kᵦ = 2
numbers.Kᵧ = 2
numbers.U = 1
numbers.V = 2

MaxStorageRevenue.evaluate_acceptance_real_time!(prb)

@test prb.cache.acceptance_real_time[:,:,1,1] == [1 1; 0 1]
@test prb.cache.acceptance_real_time[:,:,1,2] == [1 0; 1 1]
