using Pkg
Pkg.instantiate()

using Revise

Pkg.activate(dirname(@__DIR__))
Pkg.instantiate()

using OptimalEnergyBid
@info("""
This session is using OptimalEnergyBid with Revise.jl.
For more information visit https://timholy.github.io/Revise.jl/stable/.
""")
