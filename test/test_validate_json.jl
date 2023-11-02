cases = joinpath(dirname(dirname(@__FILE__)), "cases")

@test isnothing(validate_json(joinpath(cases, "toy_case.json")))
@test isnothing(validate_json(joinpath(cases, "deterministc_case.json")))
@test isnothing(validate_json(joinpath(cases, "stochastic_case.json")))
