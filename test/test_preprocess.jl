prb = OptimalEnergyBid.Problem()

numbers = prb.numbers
random = prb.random
data = prb.data

numbers.periods_per_day = 2
numbers.days = 1
numbers.first_period = 2
numbers.days = 1
numbers.units = 1
numbers.buses = 1
numbers.duration = 2
numbers.real_time_steps = 2
numbers.day_ahead_steps = 2
numbers.period_of_day_ahead_bid = 1
numbers.period_of_day_ahead_clear = 2

random.markov_transitions = [[0.5 0.5 0.5], [0.5 0.5 0.5; 0.5 0.5 0.5]]
random.prices_real_time = [[[5.0, 3.0, 7.0]], [[1.0, 3.0, 2.0]]]
random.prices_day_ahead = [[[[5.0, 3.0, 7.0]], [[1.0, 3.0, 2.0]]]]
data.prices_real_time_curve = [[[9.0, 6.0]], [[0.0, 1.0]]]
data.prices_day_ahead_curve = [[[[9.0, 6.0]], [[0.0, 1.0]]]]
data.unit_to_bus = [1, 2]

OptimalEnergyBid._preprocess!(prb)

@test prb.cache.acceptance_real_time == [[[0 0], [0 0], [0 1]], [[1 1], [1 1], [1 1]]]
@test prb.cache.acceptance_day_ahead == [[[[0 0], [0 0], [0 1]], [[1 1], [1 1], [1 1]]]]
