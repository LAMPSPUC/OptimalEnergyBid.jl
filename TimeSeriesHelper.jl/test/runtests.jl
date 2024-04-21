using TimeSeriesHelper, Test

history = TimeSeriesHelper.History()
T = 3
P = 2
N = 2

history.prices_real_time = [[1.1, 2.1], [1.3, 2.3], [1.2, 2.2]]
history.prices_day_ahead = [[1.5, 2.9], [1.4, 2.6], [1.1, 2.7], [1, 2.6], [1, 2], [1.8, 2]]
history.inflow = [[1.2, 2.2], [1.1, 2.1], [1.3, 2.3]]

h = TimeSeriesHelper.build_serial_history(history, T, P)

@test h == [
    [1.1, 2.1, 1.5, 2.9, 1.4, 2.6, 1.2, 2.2],
    [1.3, 2.3, 1.4, 2.6, 1.1, 2.7, 1.1, 2.1],
    [1.2, 2.2, 1.1, 2.7, 1.0, 2.6, 1.3, 2.3],
]

m, o = TimeSeriesHelper.estimate_hmm(h, N)

matrix = TimeSeriesHelper.build_markov_transition(m, T)

rt, da, inflow = TimeSeriesHelper.build_scenarios(o, T, P, 5, 2, 2, 2)
