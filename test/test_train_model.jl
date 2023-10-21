using MaxStorageRevenue, SDDP, HiGHS  

prb = MaxStorageRevenue.Problem()

numbers = prb.numbers
random = prb.random_variables
data = prb.data
options = prb.options

values_beta = zeros(2,1,4)
values_gamma = zeros(2,1,2,2)
probabilities = zeros(2,4)
probabilities[:,:] .= 0.5
values_beta[:,:,:] .= 10.0
values_gamma[:,:,:,:] .= 9.0
random.πᵦ = values_beta
random.ωᵦ = probabilities
random.πᵧ = values_gamma
random.ωᵧ = probabilities
numbers.N = 2
numbers.n₀ = 2
numbers.I = 1
numbers.T = 4
numbers.Kᵦ = 2
numbers.Kᵧ = 2
numbers.U = 1
numbers.V = 2

data.V_max = ones(2)
data.V_min = zeros(2)
data.V_0 = ones(2)

options.optimizer = HiGHS.Optimizer

model = MaxStorageRevenue.build_model(prb)

SDDP.train(model)