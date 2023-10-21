using MaxStorageRevenue, SDDP  

prb = MaxStorageRevenue.Problem()

numbers = prb.numbers
random = prb.random_variables
data = prb.data

values = zeros(2,1,4)
probabilities = zeros(2,4)
probabilities[:,:] .= 0.5
values[:,:,:] .= 10.0
random.πᵦ = values
random.ωᵦ = probabilities
random.πᵧ = values
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

model = MaxStorageRevenue.build_model(prb)
