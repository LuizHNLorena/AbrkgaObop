mutable struct OBOPDataset
    file_name::String
    total_voters::Int64
    total_itens::Int64
    item_names::Array{String,1}
    C::Array{Int64,2}
    D::Array{Int64,2}
    interval_init::Array{Float64,1}
end

mutable struct OBOPSolution
    id::Int64
    objective::Int64
    bucket::Array{Int64,1}
    start_time::Float64
    total_time::Float64
    generation::Int64
    local_search::Bool
    function OBOPSolution(n,start_time)
        new(0,typemin(Int64),zeros(Int64,n),start_time,0.0,0,false)
    end
end

mutable struct OBOPStatistics
    elite_mean::Array{Float64,1}
    elite_std::Array{Float64,1}
    pop_mean::Array{Float64,1}
    pop_std::Array{Float64,1}
    best_generations::Array{Int64,1}
    time_generations::Array{Float64,1}
    time_total::Float64
    time_best::Float64
end