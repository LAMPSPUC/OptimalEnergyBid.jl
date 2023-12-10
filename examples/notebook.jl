### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ af7a6e30-9723-11ee-18f6-2552c59ac981
begin
	import Pkg
	Pkg.activate("..")
	using OptimalEnergyBid, HiGHS, Images
end

# ╔═╡ 94c16ad4-7dbf-49cb-beda-f301ac7d8e53
md"""
## Import packages
"""

# ╔═╡ 6161e8fc-ccf8-47bb-819a-6fae07c008bb
md"""
## Deterministic case
**Esse caso conta com 2 usinas, o preço real time é constante e maior que o preço day ahead, que também é constante.**
"""

# ╔═╡ 71ec49f5-5b71-43e5-8e8a-e7f4e369618a
begin
	prb = create_problem(joinpath(dirname(@__DIR__), "cases", "deterministic.json"))
	set_optimizer!(prb, HiGHS.Optimizer)
	build_model!(prb)
	train!(prb)
	simulate!(prb, 1)
	plot_all(prb, 1, "")
end

# ╔═╡ 5f05e0d6-d896-4151-9c37-2359fe043464
md"""
**Reservatorios terminam vazios**
"""

# ╔═╡ f7528f2f-dd8a-4a80-be11-30ca505738bc
load("volume.png")

# ╔═╡ 787576c2-b326-43c6-a06c-5fcdb75ed439
md"""
**Não tem vertimento**
"""

# ╔═╡ 84a93406-66af-4d11-bf04-fbbbbb8fa3d6
load("spillage.png")

# ╔═╡ c5e36c52-dbfc-4448-9912-e9c590bc2d94
md"""
**Toda energia é gerada**
"""

# ╔═╡ c7534d90-1de7-44ec-b3d1-2e0fc26ff3ac
load("generation.png")

# ╔═╡ e27798d8-2e94-41a0-8af8-07c64835d421
md"""
**Sem oferta DA**
"""

# ╔═╡ 84f7962e-00b2-443c-b218-7d4e3f8f55b4
load("day_ahead_bid_1_1_1.png")

# ╔═╡ 623ec462-7313-4185-975b-9d05e2070695
md"""
**Oferta RT**
"""

# ╔═╡ 9aae9053-7af3-44d7-bf27-76b14a0db7f5
load("real_time_bid_1_1.png")

# ╔═╡ e8b1ff03-9a79-4c28-8037-f0ab351468b7
md"""
**Preço aumenta na terceira hora hora**
"""

# ╔═╡ 2793fc42-c43f-4b44-a4cd-f9491e399168
begin
	for i in 1:(prb.numbers.I)
	    prb.random.πᵦ[3][i][1] = 2.5
	end
	build_model!(prb)
	train!(prb)
	simulate!(prb, 1)
	plot_all(prb, 1, "")
end

# ╔═╡ dcb25596-8528-4c4c-ac68-2a6560e96ff2
load("volume.png")

# ╔═╡ c4bb7c7c-856d-4ac5-827c-a35e19d57da1
load("spillage.png")

# ╔═╡ 68bc5bfd-5733-4fb7-a4cd-b1d816625bd8
md"""
**Guarda energia na segunda hora para gerar na terceira.**
"""

# ╔═╡ d46ee75b-494a-47e8-a89e-8c78d108e88c
load("generation.png")

# ╔═╡ 8391884a-f5e9-4f74-a6d6-231633b50d83
load("day_ahead_bid_1_1_1.png")

# ╔═╡ d2387568-6ace-4ee9-b9fb-79e711f69d37
load("real_time_bid_1_1.png")

# ╔═╡ b3f6833c-b9c7-490c-8785-173407261b54
md"""
**Preço DA maior que RT**
"""

# ╔═╡ 5972566b-58c1-45ba-bd3b-0353516b4cb4
begin
	for i in 1:(prb.numbers.I)
	    prb.random.πᵧ[1][2][i][1] = 3.0
	end
	build_model!(prb)
	train!(prb)
	simulate!(prb, 1)
	plot_all(prb, 1, "")
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
**Restrição de rampa**
"""

# ╔═╡ f37e8a4f-512e-4cc6-bd2c-355c4c5612c8
begin
	prb2 = create_problem(joinpath(dirname(@__DIR__), "cases", "deterministic.json"))
	set_optimizer!(prb2, HiGHS.Optimizer)
	
	set_bool_parameter!(prb2, ParameterBool.UseRampUp, true)
	set_bool_parameter!(prb2, ParameterBool.UseRampDown, true)
	set_float_parameter!(prb2, ParameterFloat.PenaltyRampDown, 100.0)
	
	prb2.data.ramp_up = [0.1, 0.1]
	prb2.data.ramp_down = [0.1, 0.1]
	prb2.data.generation_initial = [0.1, 0.1]
	
	build_model!(prb2)
	train!(prb2)
	simulate!(prb2)
	plot_all(prb2, 1, "")
end

# ╔═╡ 213a0337-a34b-4af3-aaa7-4cdd99ac691a
load("volume.png")

# ╔═╡ 8cfac6aa-b56f-4ef9-805d-058e2cbf99aa
md"""
**Obrigado a verter**
"""

# ╔═╡ 59b650ab-4779-485a-b4a9-979bd7383376
load("spillage.png")

# ╔═╡ e6e4fa17-1ee5-4c48-9c91-0971876e44d9
md"""
**Rampa de geração**
"""

# ╔═╡ 76712d9a-62c8-4907-8186-6cd51a22c50a
load("generation.png")

# ╔═╡ fc6b76fb-b565-453f-8da4-6256a056e05b
load("day_ahead_bid_1_1_1.png")

# ╔═╡ 267d6a5c-1ceb-459d-87e5-08dd5ea38c11
load("real_time_bid_1_1.png")

# ╔═╡ c5dc745c-ade3-4ce0-b8a8-ee90786f10dc
md"""
## Stochastic case
**Esse caso conta com 2 usinas, o preço real time é maior que o preço day ahead.**
"""

# ╔═╡ 5c5a126b-bcea-4dfe-961d-b98b6ffb391a
begin
	prb3 = create_problem(joinpath(dirname(@__DIR__), "cases", "stochastic.json"))
	set_optimizer!(prb3, HiGHS.Optimizer)
	build_model!(prb3)
	train!(prb3)
	simulate!(prb3, 1)
	plot_all(prb3, 1, "")
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
**Preço diminui em um cenario RT: Oferta no preço DA que é maior que a esperança do preço RT**
"""

# ╔═╡ 31e13286-b414-464d-983a-b1dbd3a39ebf
begin 
	for t in 1:(prb3.numbers.T), i in 1:(prb3.numbers.I)
	    prb3.random.πᵦ[t][i] = [1.1, 1.5]
	    prb3.data.pᵦ[t][i] = [1.1, 1.5]
	end
	
	build_model!(prb3)
	train!(prb3)
	simulate!(prb3, 1)
	plot_all(prb3, 1, "")
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
**Incerteza de geração: possivel vertimento**
"""

# ╔═╡ 55de0841-c4c5-409c-beed-6a6bfb7eca39
begin
	for t in 1:(prb3.numbers.T), n in 1:2
	    prb3.random.πᵪ[t][n] = [[0.6, 0.3], [0.3, 0.6]]
	    prb3.random.ωᵪ[t][n] = [0.5, 0.5]
	end
	
	for i in 1:(prb3.numbers.I)
	    prb3.random.πᵦ[3][i] = [1.5, 5.0]
	    prb3.data.pᵦ[3][i] = [1.5, 5.0]
	end
	
	build_model!(prb3)
	train!(prb3)
	simulate!(prb3, 1)
	plot_all(prb3, 1, "")
end

# ╔═╡ 8c198f51-102d-4479-b956-11a3d4481df5
load("volume.png")

# ╔═╡ d838fc76-b123-472d-9e75-df903b5d3eae
load("spillage.png")

# ╔═╡ b3e78c7a-be71-4a38-98c6-ac7e2aecfaae
load("generation.png")

# ╔═╡ Cell order:
# ╟─94c16ad4-7dbf-49cb-beda-f301ac7d8e53
# ╠═af7a6e30-9723-11ee-18f6-2552c59ac981
# ╟─6161e8fc-ccf8-47bb-819a-6fae07c008bb
# ╠═71ec49f5-5b71-43e5-8e8a-e7f4e369618a
# ╟─5f05e0d6-d896-4151-9c37-2359fe043464
# ╟─f7528f2f-dd8a-4a80-be11-30ca505738bc
# ╟─787576c2-b326-43c6-a06c-5fcdb75ed439
# ╟─84a93406-66af-4d11-bf04-fbbbbb8fa3d6
# ╟─c5e36c52-dbfc-4448-9912-e9c590bc2d94
# ╟─c7534d90-1de7-44ec-b3d1-2e0fc26ff3ac
# ╟─e27798d8-2e94-41a0-8af8-07c64835d421
# ╟─84f7962e-00b2-443c-b218-7d4e3f8f55b4
# ╟─623ec462-7313-4185-975b-9d05e2070695
# ╟─9aae9053-7af3-44d7-bf27-76b14a0db7f5
# ╟─e8b1ff03-9a79-4c28-8037-f0ab351468b7
# ╟─2793fc42-c43f-4b44-a4cd-f9491e399168
# ╟─dcb25596-8528-4c4c-ac68-2a6560e96ff2
# ╟─c4bb7c7c-856d-4ac5-827c-a35e19d57da1
# ╟─68bc5bfd-5733-4fb7-a4cd-b1d816625bd8
# ╟─d46ee75b-494a-47e8-a89e-8c78d108e88c
# ╟─8391884a-f5e9-4f74-a6d6-231633b50d83
# ╟─d2387568-6ace-4ee9-b9fb-79e711f69d37
# ╟─b3f6833c-b9c7-490c-8785-173407261b54
# ╠═5972566b-58c1-45ba-bd3b-0353516b4cb4
# ╟─698f4b95-852c-40cd-b125-8d1426b5c6f2
# ╟─9578f57b-7531-406b-8078-2bff6fd549c2
# ╟─7c6cf9f4-4828-4238-ab2c-b87f5488e2af
# ╟─93cf9a02-29d2-4c36-87ba-6ab20d86c152
# ╟─1502015b-5663-47d4-99f8-ebae1b347ec1
# ╟─43cdaf9c-754c-4ea2-986e-16ea22cd7662
# ╟─f330b280-f7dd-4e1e-b50f-b08b4beb6952
# ╠═f37e8a4f-512e-4cc6-bd2c-355c4c5612c8
# ╟─213a0337-a34b-4af3-aaa7-4cdd99ac691a
# ╟─8cfac6aa-b56f-4ef9-805d-058e2cbf99aa
# ╟─59b650ab-4779-485a-b4a9-979bd7383376
# ╟─e6e4fa17-1ee5-4c48-9c91-0971876e44d9
# ╟─76712d9a-62c8-4907-8186-6cd51a22c50a
# ╟─fc6b76fb-b565-453f-8da4-6256a056e05b
# ╟─267d6a5c-1ceb-459d-87e5-08dd5ea38c11
# ╟─c5dc745c-ade3-4ce0-b8a8-ee90786f10dc
# ╠═5c5a126b-bcea-4dfe-961d-b98b6ffb391a
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
# ╠═31e13286-b414-464d-983a-b1dbd3a39ebf
# ╟─f92891c9-85cb-4308-b948-a586018276e6
# ╟─0ed061e0-7ad2-4cce-93b8-875c9c68cd29
# ╟─0c90567a-78b3-45df-a4a6-c9928fdc0349
# ╟─5e024476-ef59-4b4c-bf88-ae8ae52183a5
# ╟─282729ad-6faa-498b-8a3e-f6b461080a8c
# ╟─767e0d0f-552b-4761-a36b-0d3d9f0c9739
# ╠═55de0841-c4c5-409c-beed-6a6bfb7eca39
# ╟─8c198f51-102d-4479-b956-11a3d4481df5
# ╟─d838fc76-b123-472d-9e75-df903b5d3eae
# ╟─b3e78c7a-be71-4a38-98c6-ac7e2aecfaae