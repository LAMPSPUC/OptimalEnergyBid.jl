using MaxStorageRevenue, HiGHS

prb = create_problem(joinpath(dirname(dirname(@__FILE__)), "cases", "deterministc_case.json"))
prb.options.optimizer = HiGHS.Optimizer
build_model!(prb)
train!(prb)
simul = simulate!(prb, 2)

prb.output.day_ahead_bid
prb.output.day_ahead_clear
prb.output.real_time_bid
prb.output.generation

for i = 1:18
    @show simul[1][i][:day_ahead_clear]
end