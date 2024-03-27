history = History()
T = 3
P = 2
N = 2

history.prices_real_time = [[1, 2],[-1, 2],[1, -2]]
history.prices_day_ahead = [[-1, 2],[-1, -2],[1, -2],[1, 2],[-1, 2],[1, 2]]
history.inflow = [[1, -2],[1, 2],[-1, 2]]

h = build_serial_history(history, T, P)

m, o = estimate_hmm(h, N)

matrix = build_markov_transition(m, T)

rt = build_prices_real_time(o, T, P)