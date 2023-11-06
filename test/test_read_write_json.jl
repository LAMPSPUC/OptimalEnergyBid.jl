prb1 = Problem()

numbers = prb1.numbers
random = prb1.random
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

prb2 = create_problem(joinpath(dirname(@__DIR__), "cases", "toy.json"))

@test random.πᵦ == prb2.random.πᵦ
@test random.ωᵦ == prb2.random.ωᵦ
@test random.πᵧ == prb2.random.πᵧ
@test random.ωᵧ == prb2.random.ωᵧ
@test random.πᵪ == prb2.random.πᵪ
@test random.ωᵪ == prb2.random.ωᵪ

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

mktempdir() do path
    file = joinpath(path, "test.json")
    write_json(prb1, file)
    prb3 = create_problem(file)

    @test prb1.random.πᵦ == prb3.random.πᵦ
    @test prb1.random.ωᵦ == prb3.random.ωᵦ
    @test prb1.random.πᵧ == prb3.random.πᵧ
    @test prb1.random.ωᵧ == prb3.random.ωᵧ
    @test prb1.random.πᵪ == prb3.random.πᵪ
    @test prb1.random.ωᵪ == prb3.random.ωᵪ

    @test prb1.numbers.N == prb3.numbers.N
    @test prb1.numbers.n₀ == prb3.numbers.n₀
    @test prb1.numbers.I == prb3.numbers.I
    @test prb1.numbers.T == prb3.numbers.T
    @test prb1.numbers.Kᵦ == prb3.numbers.Kᵦ
    @test prb1.numbers.Kᵧ == prb3.numbers.Kᵧ
    @test prb1.numbers.Kᵪ == prb3.numbers.Kᵪ
    @test prb1.numbers.U == prb3.numbers.U
    @test prb1.numbers.V == prb3.numbers.V

    @test prb1.data.volume_max == prb3.data.volume_max
    @test prb1.data.volume_min == prb3.data.volume_min
    @test prb1.data.volume_initial == prb3.data.volume_initial
end
