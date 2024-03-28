using TimeSeriesHelper, Test

history = TimeSeriesHelper.History()
T = 3
P = 2
N = 2

history.prices_real_time = [[1, 2],[3, 4],[5, 6]]
history.prices_day_ahead = [[7, 8],[9, 10],[11, 12],[13, 14],[15, 16],[17, 18]]
history.inflow = [[19, 20],[21, 22],[23, 24]]

h = TimeSeriesHelper.build_serial_history(history, T, P)

@test h == [[1.0, 2.0, 7.0, 8.0, 9.0, 10.0, 19.0, 20.0],
            [3.0, 4.0, 9.0, 10.0, 11.0, 12.0, 21.0, 22.0],
            [5.0, 6.0, 11.0, 12.0, 13.0, 14.0, 23.0, 24.0]]

m, o = TimeSeriesHelper.estimate_hmm(h, N)

matrix = TimeSeriesHelper.build_markov_transition(m, T)

rt = TimeSeriesHelper.build_prices_real_time(o, T, P)

da = TimeSeriesHelper.build_prices_day_ahead(o, T, P, 2)

inflow = TimeSeriesHelper.build_inflow(o, T, P, N)