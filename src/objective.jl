function set_bid_objective!(sp)
    @stageobjective(sp, 0.0)
    return nothing
end

function set_real_time_commit_objective!(sp, prb::Problem, t::Int, k::Int)
    @stageobjective(sp, -sum(prb.random_variables.πᵦ[k,i,t]*(sp[:generation][i] - sp[:day_ahead_commit][i,1].in) for i in 1:prb.numbers.I))
    return nothing
end

function set_day_ahead_commit_objective!(sp, prb::Problem, t::Int, k::Int)
    temp = div(t-1, prb.numbers.N)+1
    @stageobjective(sp, -sum(prb.random_variables.πᵧ[k,i,temp,n]*(sp[:day_ahead_commit][i,n+prb.numbers.N-prb.numbers.V].out) for i in 1:prb.numbers.I, n in 1:prb.numbers.N))
    return nothing
end

