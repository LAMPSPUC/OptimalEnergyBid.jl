### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# ╔═╡ af7a6e30-9723-11ee-18f6-2552c59ac981
begin
    using Pkg
    Pkg.activate("..")
    using OptimalEnergyBid, HiGHS, Images
end

# ╔═╡ 94c16ad4-7dbf-49cb-beda-f301ac7d8e53
md"""
# Import packages
"""

# ╔═╡ 6161e8fc-ccf8-47bb-819a-6fae07c008bb
md"""
# Deterministic case
## Constant prices over time
- 2 units
- 2 buses
- 3 days
- 2 jours per day
- min storage is 0
- max storage is 1
- initial storage is 0.3 and 0.5
- real-time price is 2.0
- day-ahead price is 1.5
- inflow is 0.5 per unit
"""

# ╔═╡ 71ec49f5-5b71-43e5-8e8a-e7f4e369618a
begin
    prb = OptimalEnergyBid.create_problem(
        joinpath(dirname(@__DIR__), "cases", "deterministic.json")
    )
    OptimalEnergyBid.set_parameter!(
        prb, OptimalEnergyBid.Parameter.Optimizer, HiGHS.Optimizer
    )
    OptimalEnergyBid.build_model!(prb)
    OptimalEnergyBid.train!(prb)
    OptimalEnergyBid.simulate!(prb, 1)
    OptimalEnergyBid.plot_all(prb, 1, "")
end

# ╔═╡ f7528f2f-dd8a-4a80-be11-30ca505738bc
load("volume.png")

# ╔═╡ 84a93406-66af-4d11-bf04-fbbbbb8fa3d6
load("spillage.png")

# ╔═╡ c7534d90-1de7-44ec-b3d1-2e0fc26ff3ac
load("generation.png")

# ╔═╡ 84f7962e-00b2-443c-b218-7d4e3f8f55b4
load("day_ahead_bid_1_1_1.png")

# ╔═╡ 9aae9053-7af3-44d7-bf27-76b14a0db7f5
load("real_time_bid_1_1.png")

# ╔═╡ e8b1ff03-9a79-4c28-8037-f0ab351468b7
md"""
## Real-time price increases in the third hour
- real-time prices: 2.0, 2.0, 2.5, 2.0, 2.0, 2.0
"""

# ╔═╡ 2793fc42-c43f-4b44-a4cd-f9491e399168
begin
    for b in 1:(prb.numbers.buses)
        prb.random.prices_real_time[3][b][1] = 2.5
    end
    OptimalEnergyBid.build_model!(prb)
    OptimalEnergyBid.train!(prb)
    OptimalEnergyBid.simulate!(prb, 1)
    OptimalEnergyBid.plot_all(prb, 1, "")
end

# ╔═╡ dcb25596-8528-4c4c-ac68-2a6560e96ff2
load("volume.png")

# ╔═╡ c4bb7c7c-856d-4ac5-827c-a35e19d57da1
load("spillage.png")

# ╔═╡ d46ee75b-494a-47e8-a89e-8c78d108e88c
load("generation.png")

# ╔═╡ 8391884a-f5e9-4f74-a6d6-231633b50d83
load("day_ahead_bid_1_1_1.png")

# ╔═╡ d2387568-6ace-4ee9-b9fb-79e711f69d37
load("real_time_bid_1_1.png")

# ╔═╡ b3f6833c-b9c7-490c-8785-173407261b54
md"""
## Day-ahead price increases in the second hour
- day-ahead prices: 1.5, 3.0, 1.5, 1.5, 1.5, 1.5
"""

# ╔═╡ 5972566b-58c1-45ba-bd3b-0353516b4cb4
begin
    for b in 1:(prb.numbers.buses)
        prb.random.prices_day_ahead[1][2][b][1] = 3.0
    end
    OptimalEnergyBid.build_model!(prb)
    OptimalEnergyBid.train!(prb)
    OptimalEnergyBid.simulate!(prb, 1)
    OptimalEnergyBid.plot_all(prb, 1, "")
end

# ╔═╡ 698f4b95-852c-40cd-b125-8d1426b5c6f2
load("volume.png")

# ╔═╡ 9578f57b-7531-406b-8078-2bff6fd549c2
load("spillage.png")

# ╔═╡ 7c6cf9f4-4828-4238-ab2c-b87f5488e2af
load("generation.png")

# ╔═╡ 93cf9a02-29d2-4c36-87ba-6ab20d86c152
md"""
**Oferta DA**
"""

# ╔═╡ 1502015b-5663-47d4-99f8-ebae1b347ec1
load("day_ahead_bid_1_2_1.png")

# ╔═╡ 43cdaf9c-754c-4ea2-986e-16ea22cd7662
load("real_time_bid_1_1.png")

# ╔═╡ f330b280-f7dd-4e1e-b50f-b08b4beb6952
md"""
## Ramp constraints
- ramp up is 0.1
- ramp down is 0.1
"""

# ╔═╡ f37e8a4f-512e-4cc6-bd2c-355c4c5612c8
begin
    prb2 = OptimalEnergyBid.create_problem(
        joinpath(dirname(@__DIR__), "cases", "deterministic.json")
    )
    OptimalEnergyBid.set_parameter!(
        prb2, OptimalEnergyBid.Parameter.Optimizer, HiGHS.Optimizer
    )
    OptimalEnergyBid.set_parameter!(prb2, OptimalEnergyBid.Parameter.UseRampUp, true)
    OptimalEnergyBid.set_parameter!(prb2, OptimalEnergyBid.Parameter.UseRampDown, true)
    OptimalEnergyBid.set_parameter!(prb2, OptimalEnergyBid.Parameter.PenaltyRampDown, 100.0)

    prb2.data.ramp_up = [0.1, 0.1]
    prb2.data.ramp_down = [0.1, 0.1]
    prb2.data.generation_initial = [0.1, 0.1]

    OptimalEnergyBid.build_model!(prb2)
    OptimalEnergyBid.train!(prb2)
    OptimalEnergyBid.simulate!(prb2)
    OptimalEnergyBid.plot_all(prb2, 1, "")
end

# ╔═╡ 213a0337-a34b-4af3-aaa7-4cdd99ac691a
load("volume.png")

# ╔═╡ 59b650ab-4779-485a-b4a9-979bd7383376
load("spillage.png")

# ╔═╡ 76712d9a-62c8-4907-8186-6cd51a22c50a
load("generation.png")

# ╔═╡ fc6b76fb-b565-453f-8da4-6256a056e05b
load("day_ahead_bid_1_1_1.png")

# ╔═╡ 267d6a5c-1ceb-459d-87e5-08dd5ea38c11
load("real_time_bid_1_1.png")

# ╔═╡ c5dc745c-ade3-4ce0-b8a8-ee90786f10dc
md"""
# Stochastic case
## Real-time price higher than day-ahead price
- 2 units
- 2 buses
- 3 days
- 2 jours per day
- min storage is 0
- max storage is 1
- initial storage is 0.0 and 0.5
- real-time price is 1.5 and 2.0 (50% each one)
- day-ahead price is 1.0 and 1.4 (50% each one)
- inflow is 0.5 per unit
"""

# ╔═╡ 5c5a126b-bcea-4dfe-961d-b98b6ffb391a
begin
    prb3 = OptimalEnergyBid.create_problem(
        joinpath(dirname(@__DIR__), "cases", "stochastic.json")
    )
    OptimalEnergyBid.set_parameter!(
        prb3, OptimalEnergyBid.Parameter.Optimizer, HiGHS.Optimizer
    )
    OptimalEnergyBid.build_model!(prb3)
    OptimalEnergyBid.train!(prb3)
    OptimalEnergyBid.simulate!(prb3, 1)
    OptimalEnergyBid.plot_all(prb3, 1, "")
end

# ╔═╡ e3c8bb14-60f5-460e-8e45-9073807d5501
load("volume.png")

# ╔═╡ 688f508f-9579-4c55-80bd-8ad4205bbb65
load("spillage.png")

# ╔═╡ c583364c-0fc8-4ce7-aca8-f9cb198ba3ab
load("generation.png")

# ╔═╡ 5a543e95-e8c9-40a4-bde5-aa26ca0248e3
load("day_ahead_bid_1_1_1.png")

# ╔═╡ 0fca080e-833f-4bff-a012-0203d01fdd07
load("real_time_bid_1_1.png")

# ╔═╡ 807b2326-2854-41b7-a940-b62eb17c8c32
load("real_time_bid_1_2.png")

# ╔═╡ 621b4164-72c8-4abd-8b15-9112a9b54a21
load("real_time_bid_1_3.png")

# ╔═╡ cae1a069-a6ee-40ed-9700-ebd2e53c6f51
load("real_time_bid_1_4.png")

# ╔═╡ 4435d41b-edec-4558-9cf0-a97253d1e5cb
load("real_time_bid_1_5.png")

# ╔═╡ 2d3bd30b-ba40-4601-9e27-ee2b3532b797
load("real_time_bid_1_6.png")

# ╔═╡ 25bebda0-174a-4bf8-a902-136dca64f6e5
load("real_time_bid_2_1.png")

# ╔═╡ 3d5f5824-1d6a-453c-ab77-82a440ce9efc
load("real_time_bid_2_2.png")

# ╔═╡ a5ddc3a7-5bf4-481d-aac2-0ef94f7ff852
load("real_time_bid_2_3.png")

# ╔═╡ b349da40-66aa-418b-bcaf-bb6bf48f5c26
load("real_time_bid_2_4.png")

# ╔═╡ 9b86efb4-ae0a-430c-9fc9-b2965cf60998
load("real_time_bid_2_5.png")

# ╔═╡ bc96ce51-f393-40ed-b55e-bae217032c05
load("real_time_bid_2_6.png")

# ╔═╡ 2242fdbe-77f5-4d75-abc8-a21f7adfc324
md"""
## A day-ahead price scenario is greater than the expected real-time price
- real-time price is 1.1 and 1.5 (50% each one)
"""

# ╔═╡ 31e13286-b414-464d-983a-b1dbd3a39ebf
begin
    for t in 1:(prb3.numbers.duration), i in 1:(prb3.numbers.units)
        prb3.data.prices_real_time_curve[t][i] = [1.1, 1.5]
    end

    for t in 1:(prb3.numbers.duration), b in 1:(prb3.numbers.buses)
        prb3.random.prices_real_time[t][b] = [1.1, 1.5]
    end

    OptimalEnergyBid.build_model!(prb3)
    OptimalEnergyBid.train!(prb3)
    OptimalEnergyBid.simulate!(prb3, 1)
    OptimalEnergyBid.plot_all(prb3, 1, "")
end

# ╔═╡ f92891c9-85cb-4308-b948-a586018276e6
load("volume.png")

# ╔═╡ 0ed061e0-7ad2-4cce-93b8-875c9c68cd29
load("spillage.png")

# ╔═╡ 0c90567a-78b3-45df-a4a6-c9928fdc0349
load("generation.png")

# ╔═╡ 5e024476-ef59-4b4c-bf88-ae8ae52183a5
load("day_ahead_bid_1_1_1.png")

# ╔═╡ 282729ad-6faa-498b-8a3e-f6b461080a8c
load("real_time_bid_1_1.png")

# ╔═╡ 767e0d0f-552b-4761-a36b-0d3d9f0c9739
md"""
## Uncertainty in inflows
- real-time price is 1.5 and 5.0 (50% each one) in third hour
- inflow is 0.6 and 0.3 (50% each one)
"""

# ╔═╡ 55de0841-c4c5-409c-beed-6a6bfb7eca39
begin
    for t in 1:(prb3.numbers.duration), n in 1:2
        prb3.random.inflow[t][n] = [[0.6, 0.3], [0.3, 0.6]]
        prb3.random.inflow_probability[t][n] = [0.5, 0.5]
    end

    for i in 1:(prb3.numbers.units)
        prb3.data.prices_real_time_curve[3][i] = [1.5, 5.0]
    end

    for b in 1:(prb3.numbers.buses)
        prb3.random.prices_real_time[3][b] = [1.5, 5.0]
    end

    OptimalEnergyBid.build_model!(prb3)
    OptimalEnergyBid.train!(prb3)
    OptimalEnergyBid.simulate!(prb3, 1)
    OptimalEnergyBid.plot_all(prb3, 1, "")
end

# ╔═╡ 8c198f51-102d-4479-b956-11a3d4481df5
load("volume.png")

# ╔═╡ d838fc76-b123-472d-9e75-df903b5d3eae
load("spillage.png")

# ╔═╡ b3e78c7a-be71-4a38-98c6-ac7e2aecfaae
load("generation.png")

# ╔═╡ d0a31085-ab02-4d4d-a5c1-f95c67c0e502
md"""
# Risk aversion case
## Over time, the best real-time price gets much better and the worst real-time price gets a little worse.
- 2 units
- 2 buses
- 3 days
- 2 jours per day
- min storage is 0
- max storage is 100
- initial storage is 0.0 and 0.5
- real-time price is 1.5 - 0.1t and 2.0 + 2.5t (50% each one)
- day-ahead price is 1.0 and 1.4 (50% each one)
- inflow is 0.5 per unit
"""

# ╔═╡ 3d647090-4800-471f-ad98-074d8556e19b
begin
    prb4 = OptimalEnergyBid.create_problem(
        joinpath(dirname(@__DIR__), "cases", "stochastic.json")
    )
    OptimalEnergyBid.set_parameter!(
        prb4, OptimalEnergyBid.Parameter.Optimizer, HiGHS.Optimizer
    )
    for t in 1:(prb4.numbers.duration), i in 1:(prb4.numbers.units)
        prb4.data.prices_real_time_curve[t][i] = [1.5 - t * 0.1, 2.0 + 2.5^t]
    end
    for t in 1:(prb4.numbers.duration), b in 1:(prb4.numbers.buses)
        prb4.random.prices_real_time[t][b] = [1.5 - t * 0.1, 2.0 + 2.5^t]
    end
    prb4.data.volume_max = [100.0, 100.0]
    OptimalEnergyBid.build_model!(prb4)
    OptimalEnergyBid.train!(prb4)
    OptimalEnergyBid.simulate!(prb4)
    OptimalEnergyBid.plot_all(prb4, 1, "")
end

# ╔═╡ d5ab3d27-6c4a-4f49-a5cc-17d5cbcefc90
load("volume.png")

# ╔═╡ 9e6a02f0-8c2b-4fd8-b1a8-e15841cca1d3
md"""
## Worst case
"""

# ╔═╡ 153cddc0-e6c7-4019-b31c-bd2b3d697a6e
begin
    OptimalEnergyBid.set_parameter!(prb4, OptimalEnergyBid.Parameter.Lambda, 0.0)
    OptimalEnergyBid.build_model!(prb4)
    OptimalEnergyBid.train!(prb4)
    OptimalEnergyBid.simulate!(prb4)
    OptimalEnergyBid.plot_all(prb4, 1, "")
end

# ╔═╡ b14421cd-f505-47f2-80d7-e10cd20cdf47
load("volume.png")

# ╔═╡ Cell order:
# ╟─94c16ad4-7dbf-49cb-beda-f301ac7d8e53
# ╟─af7a6e30-9723-11ee-18f6-2552c59ac981
# ╟─6161e8fc-ccf8-47bb-819a-6fae07c008bb
# ╟─71ec49f5-5b71-43e5-8e8a-e7f4e369618a
# ╟─f7528f2f-dd8a-4a80-be11-30ca505738bc
# ╟─84a93406-66af-4d11-bf04-fbbbbb8fa3d6
# ╟─c7534d90-1de7-44ec-b3d1-2e0fc26ff3ac
# ╟─84f7962e-00b2-443c-b218-7d4e3f8f55b4
# ╟─9aae9053-7af3-44d7-bf27-76b14a0db7f5
# ╟─e8b1ff03-9a79-4c28-8037-f0ab351468b7
# ╟─2793fc42-c43f-4b44-a4cd-f9491e399168
# ╟─dcb25596-8528-4c4c-ac68-2a6560e96ff2
# ╟─c4bb7c7c-856d-4ac5-827c-a35e19d57da1
# ╟─d46ee75b-494a-47e8-a89e-8c78d108e88c
# ╟─8391884a-f5e9-4f74-a6d6-231633b50d83
# ╟─d2387568-6ace-4ee9-b9fb-79e711f69d37
# ╟─b3f6833c-b9c7-490c-8785-173407261b54
# ╟─5972566b-58c1-45ba-bd3b-0353516b4cb4
# ╟─698f4b95-852c-40cd-b125-8d1426b5c6f2
# ╟─9578f57b-7531-406b-8078-2bff6fd549c2
# ╟─7c6cf9f4-4828-4238-ab2c-b87f5488e2af
# ╟─93cf9a02-29d2-4c36-87ba-6ab20d86c152
# ╟─1502015b-5663-47d4-99f8-ebae1b347ec1
# ╟─43cdaf9c-754c-4ea2-986e-16ea22cd7662
# ╟─f330b280-f7dd-4e1e-b50f-b08b4beb6952
# ╟─f37e8a4f-512e-4cc6-bd2c-355c4c5612c8
# ╟─213a0337-a34b-4af3-aaa7-4cdd99ac691a
# ╟─59b650ab-4779-485a-b4a9-979bd7383376
# ╟─76712d9a-62c8-4907-8186-6cd51a22c50a
# ╟─fc6b76fb-b565-453f-8da4-6256a056e05b
# ╟─267d6a5c-1ceb-459d-87e5-08dd5ea38c11
# ╟─c5dc745c-ade3-4ce0-b8a8-ee90786f10dc
# ╟─5c5a126b-bcea-4dfe-961d-b98b6ffb391a
# ╟─e3c8bb14-60f5-460e-8e45-9073807d5501
# ╟─688f508f-9579-4c55-80bd-8ad4205bbb65
# ╟─c583364c-0fc8-4ce7-aca8-f9cb198ba3ab
# ╟─5a543e95-e8c9-40a4-bde5-aa26ca0248e3
# ╟─0fca080e-833f-4bff-a012-0203d01fdd07
# ╟─807b2326-2854-41b7-a940-b62eb17c8c32
# ╟─621b4164-72c8-4abd-8b15-9112a9b54a21
# ╟─cae1a069-a6ee-40ed-9700-ebd2e53c6f51
# ╟─4435d41b-edec-4558-9cf0-a97253d1e5cb
# ╟─2d3bd30b-ba40-4601-9e27-ee2b3532b797
# ╟─25bebda0-174a-4bf8-a902-136dca64f6e5
# ╟─3d5f5824-1d6a-453c-ab77-82a440ce9efc
# ╟─a5ddc3a7-5bf4-481d-aac2-0ef94f7ff852
# ╟─b349da40-66aa-418b-bcaf-bb6bf48f5c26
# ╟─9b86efb4-ae0a-430c-9fc9-b2965cf60998
# ╟─bc96ce51-f393-40ed-b55e-bae217032c05
# ╟─2242fdbe-77f5-4d75-abc8-a21f7adfc324
# ╟─31e13286-b414-464d-983a-b1dbd3a39ebf
# ╟─f92891c9-85cb-4308-b948-a586018276e6
# ╟─0ed061e0-7ad2-4cce-93b8-875c9c68cd29
# ╟─0c90567a-78b3-45df-a4a6-c9928fdc0349
# ╟─5e024476-ef59-4b4c-bf88-ae8ae52183a5
# ╟─282729ad-6faa-498b-8a3e-f6b461080a8c
# ╟─767e0d0f-552b-4761-a36b-0d3d9f0c9739
# ╟─55de0841-c4c5-409c-beed-6a6bfb7eca39
# ╟─8c198f51-102d-4479-b956-11a3d4481df5
# ╟─d838fc76-b123-472d-9e75-df903b5d3eae
# ╟─b3e78c7a-be71-4a38-98c6-ac7e2aecfaae
# ╟─d0a31085-ab02-4d4d-a5c1-f95c67c0e502
# ╟─3d647090-4800-471f-ad98-074d8556e19b
# ╟─d5ab3d27-6c4a-4f49-a5cc-17d5cbcefc90
# ╟─9e6a02f0-8c2b-4fd8-b1a8-e15841cca1d3
# ╟─153cddc0-e6c7-4019-b31c-bd2b3d697a6e
# ╟─b14421cd-f505-47f2-80d7-e10cd20cdf47
