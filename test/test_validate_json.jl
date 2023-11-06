cases = joinpath(dirname(dirname(@__FILE__)), "cases")

@test isnothing(validate_json(joinpath(cases, "toy.json")))
@test isnothing(validate_json(joinpath(cases, "deterministic.json")))
@test isnothing(validate_json(joinpath(cases, "stochastic.json")))
