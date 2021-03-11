using LightGraphs, SimpleWeightedGraphs

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

function objective_insertion(bucket, fitness, item, orig_bucket, dest_bucket, instance)
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

function objective_swap(bucket, fitness, itemA, itemB, instance)
    if bucket[itemA] < bucket[itemB]
        @inbounds for i in eachindex(bucket)
            if bucket[i] == bucket[itemA]
                fitness += (-2 * instance.C[itemA,i])
                fitness += (2 * instance.C[itemB,i])
            elseif bucket[itemA] < bucket[i] < bucket[itemB]
                fitness += (2 * instance.D[i,itemA])
                fitness += (2 * instance.D[itemB,i])
            elseif bucket[i] == bucket[itemB]
                fitness += (2 * instance.C[i,itemA])
                fitness += (-2 * instance.C[i,itemB])
            end
        end    
    else
        @inbounds for i in eachindex(bucket)
            if bucket[i] == bucket[itemB]
                fitness += (2 * instance.C[itemA,i])
                fitness += (-2 * instance.C[itemB,i])
            elseif bucket[itemB] < bucket[i] < bucket[itemA]
                fitness += (2 * instance.D[i,itemB])
                fitness += (2 * instance.D[itemA,i])
            elseif bucket[i] == bucket[itemA]
                fitness += (-2 * instance.C[i,itemA])
                fitness += (2 * instance.C[i,itemB])
            end
        end
    end
    return fitness
end

function neighbor_insertion(bucket, fitness, instance)
    
    best_fitness = fitness

    total_vizinhos = (2 * instance.total_itens) + 1

    # O(2n+1)
    buckets_testar = zeros(Int64, total_vizinhos)
    for i in 1:length(bucket)
        bucket[i] = 2 * bucket[i]
        buckets_testar[bucket[i]] += 1 
    end

    ordem_visita = shuffle!(collect(1:instance.total_itens))
    
    for item in ordem_visita

        fitness = best_fitness
        best_bucket = orig_bucket = bucket[item]

        for id in 1:total_vizinhos

            if buckets_testar[id] > 0 && buckets_testar[id] != orig_bucket

                # Testa colocar na esquerda
                dest_bucket = id - 1 
                fo = objective_insertion(bucket, 
                                         fitness, 
                                         item, 
                                         orig_bucket, 
                                         dest_bucket, 
                                         instance)
                if fo > best_fitness
                    best_fitness = fo
                    best_bucket = dest_bucket
                end
                
                # Testa colocar no grupo
                dest_bucket = id
                fo = objective_insertion(bucket, 
                                         fitness, 
                                         item, 
                                         orig_bucket, 
                                         dest_bucket, 
                                         instance)
                if fo > best_fitness
                    best_fitness = fo
                    best_bucket = dest_bucket
                end
            end
        end

        # Testa colocar no último lugar
        dest_bucket = total_vizinhos
        fo = objective_insertion(bucket, 
                                 fitness, 
                                 item, 
                                 orig_bucket, 
                                 dest_bucket, 
                                 instance)
        if fo > best_fitness
            best_fitness = fo
            best_bucket = dest_bucket
        end
        
        bucket[item] = best_bucket
        buckets_testar[orig_bucket] -= 1
        buckets_testar[best_bucket] += 1

        if best_bucket % 2 == 1

            # O(2n+1)
            new_id = 1
            for i in 1:total_vizinhos
                if buckets_testar[i] > 0
                    buckets_testar[i] = new_id
                    new_id += 1
                end
            end

            # O(n)
            for i in 1:length(bucket)
                bucket[i] = 2 * (buckets_testar[bucket[i]])
            end

            # O(2n+1)
            fill!(buckets_testar, 0)

            # O(n)
            for i in 1:length(bucket)
                buckets_testar[bucket[i]] += 1
            end

        end
    end

    # O(2n+1)
    new_id = 1
    for i in 1:total_vizinhos
        if buckets_testar[i] > 0
            buckets_testar[i] = new_id
            new_id += 1            
        end
    end

    # O(n)
    for i in 1:length(bucket)
        bucket[i] = buckets_testar[bucket[i]]
    end

    return best_fitness    

end

function neighbor_swap(bucket, fitness, instance)
    
    best_fitness = fitness

    ordem_visita_A = shuffle!(collect(1:instance.total_itens))
    ordem_visita_B = shuffle!(collect(1:instance.total_itens))
    
    for itemA in ordem_visita_A

        fitness = best_fitness

        best_item = itemA

        for itemB in ordem_visita_B
        
            # Não troca com o mesmo grupo
            if bucket[itemB] != bucket[itemA]
                fo = objective_swap(bucket, fitness, itemA, itemB, instance)
                if fo > best_fitness
                    best_fitness = fo
                    best_item = itemB
                end
            end

        end # For testa buckets

        if best_item != itemA
            # bucket[itemA],bucket[best_item] = bucket[best_item],bucket[itemA]
            temp = bucket[best_item]
            bucket[best_item] = bucket[itemA]
            bucket[itemA] = temp
        end

    end # For ordem visita

    return best_fitness

end

function local_search_vnd!(item::Int64,
    pop_keys::Array{Float64,2},
    pop_buckets::Array{Int64,2},
    pop_fitness::Array{Int64,1},
    instance::OBOPDataset,
    best_solution::OBOPSolution,
    generation::Int64,
    statistics::OBOPStatistics,
    ls_type::Int64)

    # Calculate the difference between each key and corresponding bucket key start
    dif = [(pop_keys[i,item] - instance.interval_init[pop_buckets[i,item]]) for i in 1:instance.total_itens]

    # Add local search count
    statistics.total_local_search += 1

    f = [neighbor_swap, neighbor_insertion]

    fo_best = pop_fitness[item]  
    neighbor = 1
    while neighbor <= 2
        fo = f[neighbor](pop_buckets[:,item], fo_best, instance)
        if fo > fo_best
            fo_best = fo
            neighbor = 1
        else
            neighbor += 1
        end
    end

    # Checa se é melhor
    if fo_best > best_solution.objective
        statistics.total_local_search_effective += 1
        best_solution.total_time = time() - best_solution.start_time
        best_solution.objective = fo_best
        for i in 1:instance.total_itens
            best_solution.bucket[i] = pop_buckets[i,item]#z[pop_buckets[i,item]]   
        end
        best_solution.generation = generation
        best_solution.local_search = false 
    end

    # ============================================================= #
    #  Modificar as chaves do individuo respeitando a diferença     #
    #  inicial que ele tinha. Pegar o inicio do bucket que ele foi  #
    #  e soma a diferença que ele tinha                             #
    # ============================================================= #
    for i in 1:instance.total_itens
        pop_keys[i,item] = instance.interval_init[pop_buckets[i,item]] + dif[i]
    end
    pop_fitness[item] = fo_best

end

function clustering_search_new(elite_size::Int64,
    index_order::Array{Int64,1},
    pop_keys::Array{Float64,2},
    pop_buckets::Array{Int64,2},
    pop_fitness::Array{Int64,1},
    instance::OBOPDataset,
    best_solution::OBOPSolution,
    generation::Int64,
    statistics::OBOPStatistics)

    # Create weighted graph
    sigma = 0.7                 # Used to make graph sparse
    graph = SimpleWeightedGraph(elite_size)
    for i in 1:elite_size - 1
        for j in i + 1:elite_size
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

    #ls = [local_search!,local_search_random!,local_search_parallel!]

    for item in index_local_search
        local_search_vnd!(index_order[item],
                    pop_keys,
                    pop_buckets,
                    pop_fitness,
                    instance,
                    best_solution,
                    generation,
                    statistics)
    end

end



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
            if size(neighbors(graph, u), 1) > 0
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
                       generation::Int64,
                       statistics::OBOPStatistics)

    # Add local search count
    statistics.total_local_search += 1

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
        for bucketVizinho in 1:totalVizinhos
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

        statistics.total_local_search_effective += 1

        best_solution.total_time = time() - best_solution.start_time
        best_solution.objective = bestObjective
        for i in 1:instance.total_itens
            best_solution.bucket[i] = z[pop_buckets[i,item]]   
        end
        best_solution.generation = generation
        best_solution.local_search = false 
    end

    
    # ============================================================= #
    #  Modificar as chaves do individuo respeitando a diferença     #
    #  inicial que ele tinha. Pegar o inicio do bucket que ele foi  #
    #  e soma a diferença que ele tinha                             #
    # ============================================================= #
    for i in 1:instance.total_itens
        pop_buckets[i,item] = z[pop_buckets[i,item]]
        pop_keys[i,item] = instance.interval_init[pop_buckets[i,item]] + dif[i]
    end
    pop_fitness[item] = bestObjective
    

    # println(pop_buckets[:,item])
    # println(pop_keys[:,item])
    # println(instance.interval_init)

    # println("ok partial LS")

end 

function local_search_random!(item::Int64,
    pop_keys::Array{Float64,2},
    pop_buckets::Array{Int64,2},
    pop_fitness::Array{Int64,1},
    instance::OBOPDataset,
    best_solution::OBOPSolution,
    generation::Int64,
    statistics::OBOPStatistics)

    # Add local search count
    statistics.total_local_search += 1

    # Calculate the difference between each key and corresponding bucket key start
    dif = [(pop_keys[i,item] - instance.interval_init[pop_buckets[i,item]]) for i in 1:instance.total_itens]

    # Index sequence to start the local search
    indexes = shuffle!(collect(1:instance.total_itens))

    # Create interval between buckets
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
        for bucketVizinho in 1:totalVizinhos
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
        statistics.total_local_search_effective += 1
        best_solution.total_time = time() - best_solution.start_time
        best_solution.objective = bestObjective
        for i in 1:instance.total_itens
            best_solution.bucket[i] = z[pop_buckets[i,item]]   
        end
        best_solution.generation = generation
        best_solution.local_search = false 
    end

    # ============================================================= #
    #  Modificar as chaves do individuo respeitando a diferença     #
    #  inicial que ele tinha. Pegar o inicio do bucket que ele foi  #
    #  e soma a diferença que ele tinha                             #
    # ============================================================= #
    
    
    for i in 1:instance.total_itens
        pop_buckets[i,item] = z[pop_buckets[i,item]]
        pop_keys[i,item] = instance.interval_init[pop_buckets[i,item]] + dif[i]
    end
    pop_fitness[item] = bestObjective

end

function local_search_parallel!(item::Int64,
    pop_keys::Array{Float64,2},
    pop_buckets::Array{Int64,2},
    pop_fitness::Array{Int64,1},
    instance::OBOPDataset,
    best_solution::OBOPSolution,
    generation::Int64,
    statistics::OBOPStatistics)

    # Add local search count
    statistics.total_local_search += 1

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

    neighbor_objective = zeros(totalVizinhos)

    for j in 1:instance.total_itens
        
        j = indexes[j]
        bucketAtual = pop_buckets[j,item]
        bestBucket = bucketAtual
        
        neighbor_objective[bucketAtual] = bestObjective

        Threads.@threads for bucketVizinho in 1:totalVizinhos
            if bucketVizinho != bucketAtual
                neighbor_objective[bucketVizinho] = objective_partial(pop_buckets[:,item], 
                                                                      originalObjective, 
                                                                      j, 
                                                                      bucketAtual, 
                                                                      bucketVizinho, 
                                                                      instance)
            end
        end

        bestBucket = argmax(neighbor_objective)

        if (bestBucket != bucketAtual)
            pop_buckets[j,item] = bestBucket
            originalObjective = neighbor_objective[bestBucket]
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

        statistics.total_local_search_effective += 1

        best_solution.total_time = time() - best_solution.start_time
        best_solution.objective = bestObjective
        for i in 1:instance.total_itens
            best_solution.bucket[i] = z[pop_buckets[i,item]]   
        end
        best_solution.generation = generation
        best_solution.local_search = false 
    end


    # ============================================================= #
    #  Modificar as chaves do individuo respeitando a diferença     #
    #  inicial que ele tinha. Pegar o inicio do bucket que ele foi  #
    #  e soma a diferença que ele tinha                             #
    # ============================================================= #
    for i in 1:instance.total_itens
        pop_buckets[i,item] = z[pop_buckets[i,item]]
        pop_keys[i,item] = instance.interval_init[pop_buckets[i,item]] + dif[i]
    end
    pop_fitness[item] = bestObjective

end 

function clustering_search(elite_size::Int64,
                           index_order::Array{Int64,1},
                           pop_keys::Array{Float64,2},
                           pop_buckets::Array{Int64,2},
                           pop_fitness::Array{Int64,1},
                           instance::OBOPDataset,
                           best_solution::OBOPSolution,
                           generation::Int64,
                           statistics::OBOPStatistics,
                           ls_type)
    
    # Create weighted graph
    sigma = 0.7                 # Used to make graph sparse
    graph = SimpleWeightedGraph(elite_size)
    for i in 1:elite_size - 1
        for j in i + 1:elite_size
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
    
    ls = [local_search!,local_search_random!,local_search_parallel!]

    for item in index_local_search
        ls[ls_type](index_order[item],
        pop_keys,
        pop_buckets,
        pop_fitness,
        instance,
        best_solution,
        generation,
        statistics)
        #= 
        local_search!(index_order[item],
                      pop_keys,
                      pop_buckets,
                      pop_fitness,
                      instance,
                      best_solution,
                      generation,
                      statistics) =#
    end

end