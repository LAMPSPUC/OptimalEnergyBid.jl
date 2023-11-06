prb = Problem()
numbers = prb.numbers
random = prb.random
probabilities = zeros(2, 4)
probabilities[:, :] .= 0.5
random.ωᵦ = probabilities
random.ωᵧ = probabilities
numbers.N = 2
numbers.n₀ = 2
numbers.I = 1
numbers.T = 4
numbers.Kᵦ = 2
numbers.Kᵧ = 2
numbers.U = 1
numbers.V = 2

graph = MaxStorageRevenue._build_graph(prb)

answer = Dict(
    0 => [(1, 0.5), (2, 0.5)],
    1 => [(3, 1.0)],
    2 => [(3, 1.0)],
    3 => [(4, 0.5), (5, 0.5)],
    4 => [(6, 1.0)],
    5 => [(6, 1.0)],
    6 => [(7, 1.0)],
    7 => [(8, 0.5), (9, 0.5)],
    8 => [(10, 0.5), (11, 0.5)],
    9 => [(10, 0.5), (11, 0.5)],
    10 => [(12, 1.0)],
    11 => [(12, 1.0)],
    12 => [(13, 0.5), (14, 0.5)],
    13 => [(15, 1.0)],
    14 => [(15, 1.0)],
    15 => [(16, 1.0)],
    16 => [(17, 0.5), (18, 0.5)],
    17 => [],
    18 => [],
)

@test keys(answer) == keys(graph.nodes)
for key in keys(answer)
    @test answer[key] == graph.nodes[key]
end
