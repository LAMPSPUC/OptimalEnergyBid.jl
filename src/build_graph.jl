function build_graph(prb::Problem)::SDDP.Graph

    numbers = prb.numbers
    graph = SDDP.LinearGraph(0)
    idx = 0
    root = idx
    last_problem = NOT
    between_day_ahead = false
    for t in 1:numbers.T
        idx, root, last_problem, between_day_ahead = add_day_ahead_bid!(graph, prb, idx, t, root, last_problem, between_day_ahead)
        idx, root, last_problem, between_day_ahead = add_day_ahead_commit!(graph, prb, idx, t, root, last_problem, between_day_ahead)
        idx, root, last_problem, between_day_ahead = add_real_time_bid!(graph, prb, idx, t, root, last_problem, between_day_ahead)
        idx, root, last_problem, between_day_ahead = add_real_time_commit!(graph, prb, idx, t, root, last_problem, between_day_ahead)
    end

    return graph
end

function add_day_ahead_bid!(graph::SDDP.Graph, prb::Problem, idx::Int, t::Int, root::Int, last_problem::ProblemType, between_day_ahead::Bool)
    numbers = prb.numbers
    cache = prb.cache

    if mod(t - numbers.U + numbers.n₀ - 1, numbers.N) == 0
        idx += 1
        SDDP.add_node(graph, idx)
        cache.problem_type[idx] = ProblemInfo(DAB, t, 1, between_day_ahead)
        if last_problem == NOT
            SDDP.add_edge(graph, root => idx, 1.0)
        else
            for k in 1:numbers.Kᵦ
                SDDP.add_edge(graph, root+k => idx, 1.0)
            end
        end
        root = idx
        last_problem = DAB
        between_day_ahead = true
    end
    return idx, root, last_problem, between_day_ahead
end

function add_day_ahead_commit!(graph::SDDP.Graph, prb::Problem, idx::Int, t::Int, root::Int, last_problem::ProblemType, between_day_ahead::Bool)
    numbers = prb.numbers
    random = prb.random_variables
    cache = prb.cache

    if mod(t - numbers.V + numbers.n₀ - 1, numbers.N) == 0
        for k in 1:numbers.Kᵧ
            idx += 1
            SDDP.add_node(graph, idx)
            cache.problem_type[idx] = ProblemInfo(DAC, t, k, between_day_ahead)
            if last_problem == DAB || last_problem == NOT
                SDDP.add_edge(graph, root => idx, random.ωᵧ[k,t])
            else
                for j in 1:numbers.Kᵦ
                    SDDP.add_edge(graph, root+j => idx, random.ωᵧ[k,t])
                end
            end
        end
        root += (last_problem == DAB || last_problem == NOT) ? 0 : numbers.Kᵦ
        last_problem = DAC
        between_day_ahead = false
    end
    return idx, root, last_problem, between_day_ahead
end

function add_real_time_bid!(graph::SDDP.Graph, prb::Problem, idx::Int, t::Int, root::Int, last_problem::ProblemType, between_day_ahead::Bool)
    numbers = prb.numbers
    cache = prb.cache

    idx += 1
    SDDP.add_node(graph, idx)
    cache.problem_type[idx] = ProblemInfo(RTB, t, 1, between_day_ahead)
    if last_problem == DAB
        SDDP.add_edge(graph, root => idx, 1.0)
    else
        for k in 1:numbers.Kᵦ
            SDDP.add_edge(graph, root+k => idx, 1.0)
        end
    end
    root = idx
    return idx, root, last_problem, between_day_ahead
end

function add_real_time_commit!(graph::SDDP.Graph, prb::Problem, idx::Int, t::Int, root::Int, _::ProblemType, between_day_ahead::Bool)
    numbers = prb.numbers
    random = prb.random_variables
    cache = prb.cache

    for k in 1:numbers.Kᵦ
        idx += 1
        SDDP.add_node(graph, idx)
        cache.problem_type[idx] = ProblemInfo(RTC, t, k, between_day_ahead)
        SDDP.add_edge(graph, root => idx, random.ωᵦ[k,t])
    end
    last_problem = RTC
    return idx, root, last_problem, between_day_ahead
end
