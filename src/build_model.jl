@enum LastProblem begin
    NOT = 1 # nothing
    RTB = 2 # Real time bid
    RTC = 3 # Real time commit
    DAB = 4 # Day ahead bid
    DAC = 5 # Day ahead commit
end

function build_graph(prb::Problem)

    numbers = prb.numbers
    random = prb.random_variables

    graph = SDDP.LinearGraph(0)
    idx = 0
    root = idx
    last_problem = NOT
    for t in 1:numbers.T
        if mod(t - numbers.U + numbers.n₀ - 1, numbers.N) == 0
            if last_problem == NOT
                idx += 1
                SDDP.add_node(graph, idx)
                SDDP.add_edge(graph, root => idx, 1.0)
                root = idx
                last_problem = DAB
            else
                idx += 1
                SDDP.add_node(graph, idx)
                for k in 1:numbers.Kᵦ
                    SDDP.add_edge(graph, root+k => idx, 1.0)
                end
                root = idx
                last_problem = DAB
            end
        end

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

        if last_problem == DAB
            idx += 1
            SDDP.add_node(graph, idx)
            SDDP.add_edge(graph, root => idx, 1.0)
            root = idx
        else
            idx += 1
            SDDP.add_node(graph, idx)
            for k in 1:numbers.Kᵦ
                SDDP.add_edge(graph, root+k => idx, 1.0)
            end
            root = idx
        end

        for k in 1:numbers.Kᵦ
            idx += 1
            SDDP.add_node(graph, idx)
            SDDP.add_edge(graph, root => idx, random.ωᵦ[k,t])
        end
        last_problem = RTC
    end

    return graph
end
