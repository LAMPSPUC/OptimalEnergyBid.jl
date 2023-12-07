prb = create_problem(joinpath(dirname(@__DIR__), "cases", "toy.json"))

set_optimizer!(prb, HiGHS.Optimizer)

build_model!(prb)
train!(prb)
simulate!(prb)
