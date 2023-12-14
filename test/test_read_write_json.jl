prb1 = OptimalEnergyBid.Problem()

numbers = prb1.numbers
random = prb1.random
data = prb1.data
options = prb1.options

numbers.periods_per_day = 1
numbers.first_period = 1
numbers.units = 1
numbers.duration = 1
numbers.real_tume_steps = 1
numbers.day_ahead_steps = 1
numbers.period_of_day_ahead_bid = 1
numbers.period_of_day_ahead_clear = 1

random.prices_real_time = [[[10.0]]]
random.prices_day_ahead = [[[[9.0]]]]
random.inflow = [[[[1.0]]]]
random.inflow_probability = [[[1.0]]]
random.markov_transitions = [ones(1, 1)]

data.volume_max = ones(1)
data.volume_min = zeros(1)
data.volume_initial = zeros(1)
data.prices_real_time_curve = [[[10.0]]]
data.prices_day_ahead_curve = [[[[9.0]]]]

prb2 = OptimalEnergyBid.create_problem(joinpath(dirname(@__DIR__), "cases", "toy.json"))

@test random.prices_real_time == prb2.random.prices_real_time
@test random.prices_day_ahead == prb2.random.prices_day_ahead
@test random.inflow == prb2.random.inflow
@test random.inflow_probability == prb2.random.inflow_probability
@test random.markov_transitions == prb2.random.markov_transitions

@test numbers.periods_per_day == prb2.numbers.periods_per_day
@test numbers.first_period == prb2.numbers.first_period
@test numbers.units == prb2.numbers.units
@test numbers.duration == prb2.numbers.duration
@test numbers.real_tume_steps == prb2.numbers.real_tume_steps
@test numbers.day_ahead_steps == prb2.numbers.day_ahead_steps
@test numbers.period_of_day_ahead_bid == prb2.numbers.period_of_day_ahead_bid
@test numbers.period_of_day_ahead_clear == prb2.numbers.period_of_day_ahead_clear

@test data.volume_max == prb2.data.volume_max
@test data.volume_min == prb2.data.volume_min
@test data.volume_initial == prb2.data.volume_initial
@test data.prices_real_time_curve == prb2.data.prices_real_time_curve
@test data.prices_day_ahead_curve == prb2.data.prices_day_ahead_curve

mktempdir() do path
    file = joinpath(path, "test.json")
    OptimalEnergyBid.write_json(prb1, file)
    prb3 = OptimalEnergyBid.create_problem(file)

    @test random.prices_real_time == prb3.random.prices_real_time
    @test random.prices_day_ahead == prb3.random.prices_day_ahead
    @test random.inflow == prb3.random.inflow
    @test random.inflow_probability == prb3.random.inflow_probability
    @test random.markov_transitions == prb3.random.markov_transitions

    @test numbers.periods_per_day == prb3.numbers.periods_per_day
    @test numbers.first_period == prb3.numbers.first_period
    @test numbers.units == prb3.numbers.units
    @test numbers.duration == prb3.numbers.duration
    @test numbers.real_tume_steps == prb3.numbers.real_tume_steps
    @test numbers.day_ahead_steps == prb3.numbers.day_ahead_steps
    @test numbers.period_of_day_ahead_bid == prb3.numbers.period_of_day_ahead_bid
    @test numbers.period_of_day_ahead_clear == prb3.numbers.period_of_day_ahead_clear

    @test data.volume_max == prb3.data.volume_max
    @test data.volume_min == prb3.data.volume_min
    @test data.volume_initial == prb3.data.volume_initial
    @test data.prices_real_time_curve == prb3.data.prices_real_time_curve
    @test data.prices_day_ahead_curve == prb3.data.prices_day_ahead_curve
end
