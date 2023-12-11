prb1 = Problem()

numbers = prb1.numbers
random = prb1.random
data = prb1.data
options = prb1.options

numbers.N = 1
numbers.n₀ = 1
numbers.I = 1
numbers.T = 1
numbers.Kᵦ = 1
numbers.Kᵧ = 1
numbers.U = 1
numbers.V = 1

random.πᵦ = [[[10.0]]]
random.πᵧ = [[[[9.0]]]]
random.πᵪ = [[[[1.0]]]]
random.ωᵪ = [[[1.0]]]
random.P = [ones(1, 1)]

data.volume_max = ones(1)
data.volume_min = zeros(1)
data.volume_initial = zeros(1)
data.pᵦ = [[[10.0]]]
data.pᵧ = [[[[9.0]]]]

prb2 = create_problem(joinpath(dirname(@__DIR__), "cases", "toy.json"))

@test random.πᵦ == prb2.random.πᵦ
@test random.πᵧ == prb2.random.πᵧ
@test random.πᵪ == prb2.random.πᵪ
@test random.ωᵪ == prb2.random.ωᵪ
@test random.P == prb2.random.P

@test numbers.N == prb2.numbers.N
@test numbers.n₀ == prb2.numbers.n₀
@test numbers.I == prb2.numbers.I
@test numbers.T == prb2.numbers.T
@test numbers.Kᵦ == prb2.numbers.Kᵦ
@test numbers.Kᵧ == prb2.numbers.Kᵧ
@test numbers.U == prb2.numbers.U
@test numbers.V == prb2.numbers.V

@test data.volume_max == prb2.data.volume_max
@test data.volume_min == prb2.data.volume_min
@test data.volume_initial == prb2.data.volume_initial
@test data.pᵦ == prb2.data.pᵦ
@test data.pᵧ == prb2.data.pᵧ

mktempdir() do path
    file = joinpath(path, "test.json")
    write_json(prb1, file)
    prb3 = create_problem(file)

    @test random.πᵦ == prb3.random.πᵦ
    @test random.πᵧ == prb3.random.πᵧ
    @test random.πᵪ == prb3.random.πᵪ
    @test random.ωᵪ == prb3.random.ωᵪ
    @test random.P == prb3.random.P

    @test numbers.N == prb3.numbers.N
    @test numbers.n₀ == prb3.numbers.n₀
    @test numbers.I == prb3.numbers.I
    @test numbers.T == prb3.numbers.T
    @test numbers.Kᵦ == prb3.numbers.Kᵦ
    @test numbers.Kᵧ == prb3.numbers.Kᵧ
    @test numbers.U == prb3.numbers.U
    @test numbers.V == prb3.numbers.V

    @test data.volume_max == prb3.data.volume_max
    @test data.volume_min == prb3.data.volume_min
    @test data.volume_initial == prb3.data.volume_initial
    @test data.pᵦ == prb3.data.pᵦ
    @test data.pᵧ == prb3.data.pᵧ
end
