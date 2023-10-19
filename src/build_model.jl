@enum LastProblem begin
    RTB = 1
    RTC = 2
    DAB = 3
    DAC = 4
end

function build_graph(prb::Problem)

    numbers = prb.numbers
    random = prb.random_variables

    # graph definition
    graph = SDDP.LinearGraph(0)
    idx = 1
    SDDP.add_node(graph, idx)
    SDDP.add_edge(graph, 0 => idx, 1.0)
    last_problem = RTB
    root = idx
    for k in 1:numbers.Kᵦ
        idx += 1
        SDDP.add_node(graph, idx)
        SDDP.add_edge(graph, root => idx, random.ωᵦ[k,1])
    end
    last_problem = RTC

    for t in 2:numbers.T

        if mod(t-1, numbers.N) == mod(numbers.U, numbers.N)
            idx += 1
            SDDP.add_node(graph, idx)
            for k in 1:numbers.Kᵦ
                SDDP.add_edge(graph, root+k => idx, 1.0)
            end
            root = idx
            last_problem = DAB
        end

        if mod(t-1, numbers.N) == mod(numbers.V, numbers.N)
            if last_problem == DAB
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
                root += numbers.Kᵦ # test
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

