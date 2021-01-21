using Random, Statistics

function execute_abrkga(instance::OBOPDataset;seed::Int64=nothing,local_search=true,debug=false,ls_type=1)

    if !isnothing(seed)
        Random.seed!(seed)
    end

    # Start timer
    time_total = time()

    # Initialize best solution
    best_solution = OBOPSolution(instance.total_itens,time_total)

    # Initialize parameters
    parameters = OBOPParameters(0.999)

    println("0.1.10")

    # Extended chromosome size
    chromosome_size_extended = instance.total_itens + 1

    # Population current
    pop_keys    = rand(chromosome_size_extended, parameters.population_size)
    pop_buckets = zeros(Int64, instance.total_itens, parameters.population_size)
    pop_fitness = zeros(Int64, parameters.population_size)

    # Decode and evaluate population fitness
    #Threads.@threads 
    for item in 1:parameters.population_size
        decoder!(item, pop_buckets, pop_keys)
        objective!(item, pop_buckets, pop_fitness, instance)
        
        if pop_fitness[item] > best_solution.objective
            best_solution.id = item
            best_solution.total_time = time() - best_solution.start_time
            best_solution.generation = 0
            if debug
                println("Generation 0 $(pop_fitness[item]) > $(best_solution.objective) $(best_solution.total_time)")
            end
            best_solution.objective = pop_fitness[item]
        end
    end

    # Best objective
    best_solution.bucket = deepcopy(pop_buckets[:,best_solution.id])
    
    # Sort pop by fitness
    index_order = sortperm(pop_fitness[1:parameters.population_size], rev=true)    # 999  akslaks

    # Get partial time
    time_partial = time() - time_total

    # Statistics
    statistics = OBOPStatistics([mean(pop_fitness[ index_order[1:parameters.elite_size] ])],
                                [ std(pop_fitness[ index_order[1:parameters.elite_size] ])],
                                [mean(pop_fitness)],
                                [ std(pop_fitness)],
                                [best_solution.objective],
                                [time_partial],
                                time_partial,
                                best_solution.total_time,
                                0,
                                0)

    # Temp population
    pop_keys_new = zeros(chromosome_size_extended, parameters.population_size)

    # Variables used inside main loop
    elite_id = non_elite_id = 0
    rhoe = 0.0
    offspring_begin = offspring_end = 0
    inicio_mutante = fim_mutante = 0

    # ========= #
    # Main loop #
    # ========= #
    generation::Int64 = 1

    while generation <= parameters.max_generations
        
        time_partial = time()

        # ========================== #
        # Start evolutionary process #
        # ========================== #

        # ============= #
        # Create elites #
        # ============= #
        for item in 1:parameters.elite_size
            pop_keys_new[:,item] = pop_keys[:,index_order[item]]
            #pop_fitness[item] = pop_fitness[index_order[item]]
            #pop_buckets[:,item] = pop_buckets[:,index_order[item]]
        
            decoder!(item, pop_buckets, pop_keys_new)
            objective!(item, pop_buckets, pop_fitness, instance)

            if pop_fitness[item] > best_solution.objective
                best_solution.id = item
                best_solution.total_time = time() - best_solution.start_time
                best_solution.generation = generation
                best_solution.local_search = false
                if debug
                    println("Generation 0 $(pop_fitness[item]) > $(best_solution.objective) $(best_solution.total_time)")
                end
                best_solution.objective = pop_fitness[item]
            end

        end 

        # ================= #
        # Create offsprings #
        # ================= #
        offspring_begin = parameters.elite_size + 1
        offspring_end = parameters.population_size - parameters.mutation_size

        for item in offspring_begin:offspring_end
            # Select an elite parent
            elite_id = rand(collect(1:parameters.elite_size))
            elite_id = index_order[elite_id]

            # Select an non elite parent
            #non_elite_id = rand(collect(offspring_begin:offspring_end))                # don't include mutants
            non_elite_id = rand(collect(offspring_begin:parameters.population_size))    # including mutants
            non_elite_id = index_order[non_elite_id]

            # Get rhoe value from non elite last key
            rhoe = 0.65 + (pop_keys[chromosome_size_extended,non_elite_id]) * (0.80 - 0.65)
    
            # Mate: including rhoe
            for j in 1:chromosome_size_extended
                # copy allele of top chromosome to the new generation or not
                if rand() < rhoe
                    pop_keys_new[j,item] = pop_keys[j,elite_id]
                else
                    pop_keys_new[j,item] = pop_keys[j,non_elite_id]    
                end
            end
  
            decoder!(item, pop_buckets, pop_keys_new)
            objective!(item, pop_buckets, pop_fitness, instance)

            if pop_fitness[item] > best_solution.objective
                best_solution.id = item
                best_solution.total_time = time() - best_solution.start_time
                best_solution.generation = generation
                best_solution.local_search = false
                if debug
                    println("Generation 0 $(pop_fitness[item]) > $(best_solution.objective) $(best_solution.total_time)")
                end
                best_solution.objective = pop_fitness[item]
            end
        end

        # ============== #
        # Create Mutants #
        # ============== #
        inicio_mutante = offspring_end + 1
        fim_mutante = parameters.population_size
        for item in inicio_mutante:fim_mutante
            pop_keys_new[:,item] = rand(chromosome_size_extended)

            decoder!(item, pop_buckets, pop_keys_new)
            objective!(item, pop_buckets, pop_fitness, instance)

            if pop_fitness[item] > best_solution.objective
                best_solution.id = item
                best_solution.total_time = time() - best_solution.start_time
                best_solution.generation = generation
                best_solution.local_search = false
                if debug
                    println("Generation 0 $(pop_fitness[item]) > $(best_solution.objective) $(best_solution.total_time)")
                end
                best_solution.objective = pop_fitness[item]
            end
        end

        # =================================== # 
        # Set temp population to the original #
        # =================================== # 
        pop_keys = pop_keys_new
        
        # =================== #
        # Sort pop by fitness #
        # =================== #
        index_order = sortperm(pop_fitness[1:parameters.population_size], rev=true)

        # ============ #
        # Local search #
        # ============ #
        if local_search
            clustering_search(parameters.elite_size,
                              index_order,
                              pop_keys,
                              pop_buckets,
                              pop_fitness,
                              instance,
                              best_solution,
                              generation,
                              statistics,ls_type)
        end
                            
        # ================= #
        # Update parameters #
        # ================= #
        update_parameters!(generation, parameters)


        # ================================== #
        # Update partial time and statistics #
        # ================================== #
        time_partial = time() - time_partial

        push!(statistics.elite_mean, mean(pop_fitness[ index_order[1:parameters.elite_size] ]))
        push!(statistics.elite_std, std(pop_fitness[ index_order[1:parameters.elite_size] ]))
        push!(statistics.pop_mean, mean(pop_fitness))
        push!(statistics.pop_std, std(pop_fitness))
        push!(statistics.best_generations, best_solution.objective)
        push!(statistics.time_generations, time_partial)
        
        generation += 1
    end

    statistics.time_total = time() - time_total
    statistics.time_best = best_solution.total_time

    return best_solution.objective, create_bucket_order(best_solution.bucket), statistics
end