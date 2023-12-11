prb = Problem()

numbers = prb.numbers
random = prb.random
data = prb.data

numbers.N = 2
numbers.n₀ = 2
numbers.I = 1
numbers.T = 2
numbers.Kᵦ = 2
numbers.Kᵧ = 2
numbers.U = 1
numbers.V = 2
numbers.D = 1

random.P = [[0.5 0.5 0.5], [0.5 0.5 0.5; 0.5 0.5 0.5]]
random.πᵦ = [[[5.0, 3.0, 7.0]], [[1.0, 3.0, 2.0]]]
random.πᵧ = [[[[5.0, 3.0, 7.0]], [[1.0, 3.0, 2.0]]]]
data.pᵦ = [[[9.0, 6.0]], [[0.0, 1.0]]]
data.pᵧ = [[[[9.0, 6.0]], [[0.0, 1.0]]]]

OptimalEnergyBid._preprocess!(prb)

@test prb.cache.acceptance_real_time == [[[0 0], [0 0], [0 1]], [[1 1], [1 1], [1 1]]]
@test prb.cache.acceptance_day_ahead == [[[[0 0], [0 0], [0 1]], [[1 1], [1 1], [1 1]]]]
