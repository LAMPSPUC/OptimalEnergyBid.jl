@enum LastProblem begin
    NOT = 1 # nothing
    RTB = 2 # Real time bid
    RTC = 3 # Real time commit
    DAB = 4 # Day ahead bid
    DAC = 5 # Day ahead commit
end

function build_graph(prb::Problem)

    numbers = prb.numbers
    graph = SDDP.LinearGraph(0)
    idx = 0
    root = idx
    last_problem = NOT
    for t in 1:numbers.T
        idx, root, last_problem = add_day_ahead_bid(graph, prb, idx, t, root, last_problem)
        idx, root, last_problem = add_day_ahead_commit(graph, prb, idx, t, root, last_problem)
        idx, root, last_problem = add_real_time_bid(graph, prb, idx, t, root, last_problem)
        idx, root, last_problem = add_real_time_commit(graph, prb, idx, t, root, last_problem)
    end

    return graph
end

function add_day_ahead_bid(graph::SDDP.Graph, prb::Problem, idx::Int, t::Int, root::Int, last_problem::LastProblem)
    numbers = prb.numbers

    if mod(t - numbers.U + numbers.n₀ - 1, numbers.N) == 0
        idx += 1
        SDDP.add_node(graph, idx)
        if last_problem == NOT
            SDDP.add_edge(graph, root => idx, 1.0)
        else
            for k in 1:numbers.Kᵦ
                SDDP.add_edge(graph, root+k => idx, 1.0)
            end
        end
        root = idx
        last_problem = DAB
    end
    return idx, root, last_problem
end

function add_day_ahead_commit(graph::SDDP.Graph, prb::Problem, idx::Int, t::Int, root::Int, last_problem::LastProblem)
    numbers = prb.numbers
    random = prb.random_variables

    if mod(t - numbers.V + numbers.n₀ - 1, numbers.N) == 0
        if last_problem == DAB || last_problem == NOT
            for k in 1:numbers.Kᵧ
                idx += 1
                SDDP.add_node(graph, idx)
                SDDP.add_edge(graph, root => idx, random.ωᵧ[k,t])
            end
        else
            for k in 1:numbers.Kᵧ
                idx += 1
                SDDP.add_node(graph, idx)
                for j in 1:numbers.Kᵦ
                    SDDP.add_edge(graph, root+j => idx, random.ωᵧ[k,t])
                end
            end
            root += numbers.Kᵦ
        end
        last_problem = DAC
    end
    return idx, root, last_problem
end

function add_real_time_bid(graph::SDDP.Graph, prb::Problem, idx::Int, _::Int, root::Int, last_problem::LastProblem)
    numbers = prb.numbers

    idx += 1
    SDDP.add_node(graph, idx)
    if last_problem == DAB
        SDDP.add_edge(graph, root => idx, 1.0)
    else
        for k in 1:numbers.Kᵦ
            SDDP.add_edge(graph, root+k => idx, 1.0)
        end
    end
    root = idx
    return idx, root, last_problem
end

function add_real_time_commit(graph::SDDP.Graph, prb::Problem, idx::Int, t::Int, root::Int, _::LastProblem)
    numbers = prb.numbers
    random = prb.random_variables

    for k in 1:numbers.Kᵦ
        idx += 1
        SDDP.add_node(graph, idx)
        SDDP.add_edge(graph, root => idx, random.ωᵦ[k,t])
    end
    last_problem = RTC
    return idx, root, last_problem
end
