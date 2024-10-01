using OptimalEnergyBid
using TimeSeriesHelper

directory = "C:\\Users\\thiag\\Documents\\Data\\";
start = 20240810;
stop = 20240824;

day_ahead = TimeSeriesHelper.read_miso_da_lmps(
    directory, start, stop
)

real_time = TimeSeriesHelper.read_miso_rt_lmps(
    directory, start, stop
)

wind = TimeSeriesHelper.read_open_meteo_json(
    directory, "wind_speed_10m", start, stop
)

wind3 = wind3[(end - 744):end, 4:5]
solar3 = solar3[(end - 744):end, :]
rt3 = rt3[:, 1:2]
da3 = da3[:, 1:2]

wind4 = vec(wind3)
solar4 = vec(solar3)
rt4 = vec(rt3)
da4 = vec(da3)

windl, _ = size(wind3)
solarl, _ = size(solar3)
rtl, _ = size(rt3)
dal, _ = size(da3)

wind5 = [wind4[i:windl:end] for i in 1:windl]
solar5 = [solar4[i:solarl:end] for i in 1:solarl]
rt5 = [rt4[i:rtl:end] for i in 1:rtl]
da5 = [da4[i:dal:end] for i in 1:dal]

history = TimeSeriesHelper.History()
history.prices_real_time = rt5
history.prices_day_ahead = da5
history.inflow = wind5

h = TimeSeriesHelper.build_serial_history(history, 745, 24)

m, o = TimeSeriesHelper.estimate_hmm(h, 5)
