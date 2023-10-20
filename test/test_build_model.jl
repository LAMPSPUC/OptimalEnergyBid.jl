using MaxStorageRevenue, SDDP  
prb = MaxStorageRevenue.Problem()

numbers = prb.numbers
random = prb.random_variables

values = zeros(4,1,4)
probabilities = zeros(4,4)

probabilities[:,:] .= 0.25
values[:,:,:] .= 10.0

random.πᵦ = values
random.ωᵦ = probabilities
random.πᵧ = values
random.ωᵧ = probabilities

numbers.N = 2
numbers.n₀ = 2
numbers.I = 1
numbers.T = 4
numbers.Kᵦ = 4
numbers.Kᵧ = 4
numbers.U = 1
numbers.V = 2

MaxStorageRevenue.build_graph(prb)