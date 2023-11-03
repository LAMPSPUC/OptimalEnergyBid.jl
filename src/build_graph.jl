"""Creates the SDDP graph"""
function _build_graph(prb::Problem)::SDDP.Graph
    numbers = prb.numbers
    graph = SDDP.LinearGraph(0)
    idx = 0
    root = idx
    last_problem = ProblemType.NOT
    for t in 1:(numbers.T)
        idx, root, last_problem = _add_day_ahead_bid!(
            graph, prb, idx, t, root, last_problem
        )
        idx, root, last_problem = _add_day_ahead_clear!(
            graph, prb, idx, t, root, last_problem
        )
        idx, root, last_problem = _add_real_time_bid!(
            graph, prb, idx, t, root, last_problem
        )
        idx, root, last_problem = _add_real_time_clear!(
            graph, prb, idx, t, root, last_problem
        )
    end

    return graph
end

"""Adds the day ahead offer node"""
function _add_day_ahead_bid!(
    graph::SDDP.Graph,
    prb::Problem,
    idx::Int,
    t::Int,
    root::Int,
    last_problem::ProblemType.T,
)
    numbers = prb.numbers
    cache = prb.cache

    if mod(t - numbers.U + numbers.n₀ - 1, numbers.N) == 0
        idx += 1
        SDDP.add_node(graph, idx)
        cache.problem_info[idx] = ProblemInfo(ProblemType.DAB, t, 1)
        if last_problem == ProblemType.NOT
            SDDP.add_edge(graph, root => idx, 1.0)
        else
            for k in 1:(numbers.Kᵦ)
                SDDP.add_edge(graph, root + k => idx, 1.0)
            end
        end
        root = idx
        last_problem = ProblemType.DAB
    end
    return idx, root, last_problem
end

"""Adds the day ahead clear nodes"""
function _add_day_ahead_clear!(
    graph::SDDP.Graph,
    prb::Problem,
    idx::Int,
    t::Int,
    root::Int,
    last_problem::ProblemType.T,
)
    numbers = prb.numbers
    random = prb.random_variables
    cache = prb.cache

    if mod(t - numbers.V + numbers.n₀ - 1, numbers.N) == 0
        for k in 1:(numbers.Kᵧ)
            idx += 1
            SDDP.add_node(graph, idx)
            cache.problem_info[idx] = ProblemInfo(ProblemType.DAC, t, k)
            temp = div(t - 1, prb.numbers.N) + 1
            if last_problem == ProblemType.RTC
                for j in 1:(numbers.Kᵦ)
                    SDDP.add_edge(graph, root + j => idx, random.ωᵧ[k, temp])
                end
            else
                SDDP.add_edge(graph, root => idx, random.ωᵧ[k, temp])
            end
        end
        root += (last_problem == ProblemType.RTC) ? numbers.Kᵦ : 0
        last_problem = ProblemType.DAC
    end
    return idx, root, last_problem
end

"""Adds the real time offer node"""
function _add_real_time_bid!(
    graph::SDDP.Graph,
    prb::Problem,
    idx::Int,
    t::Int,
    root::Int,
    last_problem::ProblemType.T,
)
    numbers = prb.numbers
    cache = prb.cache

    idx += 1
    SDDP.add_node(graph, idx)
    cache.problem_info[idx] = ProblemInfo(ProblemType.RTB, t, 1)
    if last_problem == ProblemType.DAB
        SDDP.add_edge(graph, root => idx, 1.0)
    else
        for k in 1:(numbers.Kᵦ)
            SDDP.add_edge(graph, root + k => idx, 1.0)
        end
    end
    root = idx
    return idx, root, last_problem
end

"""Adds the real time clear nodes"""
function _add_real_time_clear!(
    graph::SDDP.Graph, prb::Problem, idx::Int, t::Int, root::Int, _::ProblemType.T
)
    numbers = prb.numbers
    random = prb.random_variables
    cache = prb.cache

    for k in 1:(numbers.Kᵦ)
        idx += 1
        SDDP.add_node(graph, idx)
        cache.problem_info[idx] = ProblemInfo(ProblemType.RTC, t, k)
        SDDP.add_edge(graph, root => idx, random.ωᵦ[k, t])
    end
    last_problem = ProblemType.RTC
    return idx, root, last_problem
end
