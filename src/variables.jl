"""creates volume variables specified in data"""
function add_variable_volume(sp, prb::Problem)
    @variable(
        sp,
        prb.data.V_min[i] <= reservoir[i=1:prb.numbers.I] <= prb.data.V_max[i],
        SDDP.State,
        initial_value = prb.data.V_0[i]
    )
end