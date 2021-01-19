using LightGraphs, SimpleWeightedGraphs

function objective_partial(bucket, fitness, item, orig_bucket, dest_bucket, instance)
    if orig_bucket < dest_bucket
        @inbounds for i in eachindex(bucket)
            if bucket[i] == orig_bucket
                fitness += ( -2 * instance.C[item,i] )
            elseif orig_bucket < bucket[i] < dest_bucket
                # fitness += (2  *(instance.C[i,item] - instance.C[item,i]))
                fitness += (2 * instance.D[i,item])
            elseif bucket[i] == dest_bucket
                fitness += (2 * instance.C[i,item])
            end
        end
    else
        @inbounds for i in eachindex(bucket)
            if bucket[i] == orig_bucket
                fitness += ( -2 * instance.C[i,item] )
            elseif dest_bucket < bucket[i] < orig_bucket
                # fitness += (2 *(instance.C[item,i] - instance.C[i,item]))
                fitness += (2 * instance.D[item,i])
            elseif bucket[i] == dest_bucket
                fitness += (2 * instance.C[item,i])
            end
        end
    end
    return fitness
end

function weighted_label_propagation(graph)

    n = nv(graph)

    # Vertices communities
    labels = collect(1:n)

    # Index to start visiting
    visit_order = collect(1:n)

    # Total neighbor labels
    labels_total = Array{Float64}(undef, n)

    # Main loop WLP
    iteration = 1
    best_label = 0
    moviments = true
    while moviments
        moviments = false
        shuffle!(visit_order)
        for u in visit_order 
            if size(neighbors(graph,u),1) > 0
                fill!(labels_total, 0.0)
                for v in neighbors(graph, u) 
                    labels_total[labels[v]] += graph.weights[u,v]
                end
                best_label = findmax(labels_total)[2]
                if best_label != labels[u]
                    moviments = true
                    labels[u] = best_label
                end
            end
        end
        iteration += 1
    end

    # Create groups and select one random representant from each group
    groups = [[] for _ in 1:n]
    for i in 1:n
        push!(groups[labels[i]], i)
    end

    # Select one random representant from each group
    index_local_search = []
    for i in 1:n
        if size(groups[i], 1) > 0
            push!(index_local_search, groups[i][rand(collect(1:size(groups[i], 1)))])
        end
    end

    return index_local_search
end

function local_search!(item::Int64,
                       pop_keys::Array{Float64,2},
                       pop_buckets::Array{Int64,2},
                       pop_fitness::Array{Int64,1},
                       instance::OBOPDataset,
                       best_solution::OBOPSolution,
                       generation::Int64)

    # Calculate the difference between each key and corresponding bucket key start
    dif = [(pop_keys[i,item] - instance.interval_init[pop_buckets[i,item]]) for i in 1:instance.total_itens]

    # Index sequence to start the local search
    indexes = sortperm(dif)

    # Create interval between buckets
    # bucket = 2 * bucket
    pop_buckets[:,item] = pop_buckets[:,item] * 2

    # =================== #
    # Inicia refinamento  #
    # =================== #
    originalObjective = currentObjective = bestObjective = pop_fitness[item]
    totalVizinhos = (2 * instance.total_itens) + 1
    bestBucket = nothing

    for j in 1:instance.total_itens
        j = indexes[j]
        bucketAtual = pop_buckets[j,item]
        bestBucket = bucketAtual
        for bucketVizinho in 0:totalVizinhos
            if bucketVizinho != bucketAtual
                currentObjective = objective_partial(pop_buckets[:,item], 
                                   originalObjective, 
                                   j, 
                                   bucketAtual, 
                                   bucketVizinho, 
                                   instance)
                if currentObjective > bestObjective
                    bestObjective = currentObjective
                    bestBucket = bucketVizinho
                end
            end
        end
        if (bestBucket != bucketAtual)
            pop_buckets[j,item] = bestBucket
            originalObjective = bestObjective
        end
    end

    # ========================================================== #
    # Reindexa os buckets, pois podem estar em um intervalo > n  #
    # ========================================================== #
    z = zeros(Int64, totalVizinhos)
    id = 1
    for i in 1:instance.total_itens
        if z[ pop_buckets[i,item] ] == 0
            z[ pop_buckets[i,item] ] = id
            id += 1
        end  
    end

    id = 1
    for i in 1:totalVizinhos
        if z[i] != 0
            z[i] = id
            id += 1
        end
    end

    # Checa se é melhor
    if bestObjective > best_solution.objective
        best_solution.total_time = time() - best_solution.start_time
        best_solution.objective = bestObjective
        for i in 1:instance.total_itens
            best_solution.bucket[i] = z[pop_buckets[i,item]]   
        end
        best_solution.generation = generation
        best_solution.local_search = false 
    end

    #= 
    # ============================================================= #
    #  Modificar as chaves do individuo respeitando a diferença     #
    #  inicial que ele tinha. Pegar o inicio do bucket que ele foi  #
    #  e soma a diferença que ele tinha                             #
    # ============================================================= #
    for i in 1:instance.total_itens
    pop_buckets[i,item] = z[pop_buckets[i,item]]
    pop_keys[i,item] = instance.interval_init[pop_buckets[i,item]] + dif[i]
    end
    pop_fitness[item] = bestObjective =#

    # println(pop_buckets[:,item])
    # println(pop_keys[:,item])
    # println(instance.interval_init)

    # println("ok partial LS")

end

function pearson_correlation(X, Y, n)
    correlation::Float64 = 0.0
    sumXY::Float64 = 0.0
    sumX2::Float64 = 0.0
    sumY2::Float64 = 0.0
    sumX::Float64 = 0.0
    sumY::Float64 = 0.0
    for j in 1:n
        sumX += X[j]
        sumX2 += X[j] * X[j]
        sumXY += X[j] * Y[j]
        sumY += Y[j]
        sumY2 += Y[j] * Y[j]
    end
    # Pearson Correlation
    correlation = ((n * sumXY) - (sumX * sumY) ) / (sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY)))
    return correlation
end

function clustering_search(elite_size::Int64,
                           index_order::Array{Int64,1},
                           pop_keys::Array{Float64,2},
                           pop_buckets::Array{Int64,2},
                           pop_fitness::Array{Int64,1},
                           instance::OBOPDataset,
                           best_solution::OBOPSolution,
                           generation::Int64)
    
    # Create weighted graph
    sigma = 0.7                 # Used to make graph sparse
    graph = SimpleWeightedGraph(elite_size)
    for i in 1:elite_size - 1
        for j in i+1:elite_size
            weight = pearson_correlation(pop_keys[:,index_order[i]],
                                              pop_keys[:,index_order[j]],
                                              instance.total_itens)
            if weight >= sigma
                add_edge!(graph, i, j, weight)
            end
        end
    end
    
    # Return the index of the chromosomes that the LS will be applied
    index_local_search = weighted_label_propagation(graph)
    
    for item in index_local_search
        local_search!(index_order[item],
                      pop_keys,
                      pop_buckets,
                      pop_fitness,
                      instance,
                      best_solution,
                      generation)
    end

end