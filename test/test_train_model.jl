using MaxStorageRevenue, SDDP, HiGHS  

prb = MaxStorageRevenue.Problem()

numbers = prb.numbers
random = prb.random_variables
data = prb.data
options = prb.options

values_beta = zeros(1,1,1)
values_gamma = zeros(1,1,1,1)
probabilities = zeros(1,1)
probabilities[:,:] .= 1.0
values_beta[:,:,:] .= 10.0
values_gamma[:,:,:,:] .= 9.0
random.πᵦ = values_beta
random.ωᵦ = probabilities
random.πᵧ = values_gamma
random.ωᵧ = probabilities
numbers.N = 1
numbers.n₀ = 1
numbers.I = 1
numbers.T = 1
numbers.Kᵦ = 1
numbers.Kᵧ = 1
numbers.U = 1
numbers.V = 1

data.V_max = ones(1)
data.V_min = zeros(1)
data.V_0 = ones(1)

options.optimizer = HiGHS.Optimizer

model = MaxStorageRevenue.build_model(prb)

SDDP.train(model, time_limit = 10.0)

