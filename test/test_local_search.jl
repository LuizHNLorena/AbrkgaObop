using Random, LightGraphs, SimpleWeightedGraphs

@testset "Testing local_search.jl" begin

    @testset "Testing pearson_correlation" begin
        
        # Check equal
        b1 = [i/6 for i in 1:6]
        b2 = [i/6 for i in 1:6]

        @test AbrkgaObop.pearson_correlation(b1,b2,6) == 1.0
        
        # Check reverse
        b3 = reverse(b1)
        
        @test AbrkgaObop.pearson_correlation(b1,b3,6) ≈ -1.0
    end;

    @testset "Testing weighted_label_propagation" begin

        Random.seed!(0)

        keys = [0.16666666666666666 0.159 0.84;
                0.3333333333333333  0.32  0.82;
                0.5                 0.49  0.65;
                0.6666666666666666  0.65  0.49; 
                0.8333333333333334  0.82  0.32;
                1.0                 0.84  0.159]
    
        # Create weighted graph
        sigma = 0.7                 # Used to make graph sparse
        
        n_itens = size(keys,1)
        n_voters = size(keys,2)

        graph = SimpleWeightedGraph(n_voters)
        for i in 1:n_voters-1
            for j in i+1:n_voters
                weight = AbrkgaObop.pearson_correlation(keys[:,i],keys[:,j],n_itens)
                if weight >= sigma
                    add_edge!(graph, i, j, weight)
                end
            end
        end

        # Return the index of the chromosomes that the LS will be applied
        index_local_search = AbrkgaObop.weighted_label_propagation(graph)

        @test index_local_search == [1,3]

    end

    @testset "Testing objective_partial" begin

        instance = read_dataset("datasets/movie.toi")

        bucket = [0 0;
                  0 0;
                  0 0;
                  0 0;
                  0 0;
                  0 0]
        keys = [0.16666666666666666 0.159;
                0.3333333333333333  0.32;
                0.5                 0.49;
                0.6666666666666666  0.65; 
                0.8333333333333334  0.82;
                1.0                 0.84]
        fitness = [0,0]
        AbrkgaObop.decoder!(1,bucket,keys)
        AbrkgaObop.objective!(1,bucket,fitness,instance)

        # Check i -> j
        fitness_from_i_j = AbrkgaObop.objective_partial(bucket[:,1], fitness[1], 1, 1, 6, instance)
        @test fitness_from_i_j == 32

        # Check j -> i
        fitness_from_j_i = AbrkgaObop.objective_partial(bucket[:,1], fitness_from_i_j, 1, 6, 1, instance)
        @test fitness_from_j_i == fitness[1]

        # Compare with another bucket with same bucket order
        AbrkgaObop.decoder!(2,bucket,keys)
        AbrkgaObop.objective!(2,bucket,fitness,instance)
        @test fitness_from_i_j == AbrkgaObop.objective_partial(bucket[:,2], fitness[2], 1, 1, 6, instance)

    end

    @testset "Testing local_search" begin

        Random.seed!(0)

        instance = read_dataset("datasets/movie.toi")

        bucket = [0 0;
                  0 0;
                  0 0;
                  0 0;
                  0 0;
                  0 0]
        keys = [0.16666666666666666 0.159;
                0.3333333333333333  0.32;
                0.5                 0.49;
                0.6666666666666666  0.65; 
                0.8333333333333334  0.82;
                1.0                 0.84]
        fitness = [0,0]

        statistics = AbrkgaObop.OBOPStatistics([],[],[],[],[],[],0.0,0.0,0,0)

        AbrkgaObop.decoder!(1,bucket,keys)
        AbrkgaObop.objective!(1,bucket,fitness,instance)

        best_solution = AbrkgaObop.OBOPSolution(instance.total_itens,time())

        AbrkgaObop.local_search!(1,keys,bucket,fitness,instance,best_solution,1,statistics)

        @test best_solution.objective == 72
        @test best_solution.bucket == [1,1,1,2,2,3]

    end

    @testset "Testing local_search_parallel" begin

        Random.seed!(0)

        instance = read_dataset("datasets/movie.toi")

        bucket = [0 0;
                  0 0;
                  0 0;
                  0 0;
                  0 0;
                  0 0]
        keys = [0.16666666666666666 0.159;
                0.3333333333333333  0.32;
                0.5                 0.49;
                0.6666666666666666  0.65; 
                0.8333333333333334  0.82;
                1.0                 0.84]
        fitness = [0,0]

        statistics = AbrkgaObop.OBOPStatistics([],[],[],[],[],[],0.0,0.0,0,0)

        AbrkgaObop.decoder!(1,bucket,keys)
        AbrkgaObop.objective!(1,bucket,fitness,instance)

        best_solution = AbrkgaObop.OBOPSolution(instance.total_itens,time())

        AbrkgaObop.local_search_parallel!(1,keys,bucket,fitness,instance,best_solution,1,statistics)

        @test best_solution.objective == 72
        @test best_solution.bucket == [1,1,1,2,2,3]

    end

    #=
    @testset "Testing clustering_search" begin

        Random.seed!(0)

        instance = read_dataset("datasets/movie.toi")

        bucket = [0 0;
                  0 0;
                  0 0;
                  0 0;
                  0 0;
                  0 0]
        keys = [0.16666666666666666 0.159;
                0.3333333333333333  0.32;
                0.5                 0.49;
                0.6666666666666666  0.65; 
                0.8333333333333334  0.82;
                1.0                 0.84]
        fitness = [0,0]
        AbrkgaObop.decoder!(1,bucket,keys)
        AbrkgaObop.objective!(1,bucket,fitness,instance)
        AbrkgaObop.decoder!(2,bucket,keys)
        AbrkgaObop.objective!(2,bucket,fitness,instance)

        best_solution = AbrkgaObop.OBOPSolution(instance.total_itens,time())

        statistics = AbrkgaObop.OBOPStatistics([],[],[],[],[],[],0.0,0.0,0,0)

        AbrkgaObop.clustering_search(2,
                                     [1,2],
                                     keys,
                                     bucket,
                                     fitness,
                                     instance,
                                     best_solution,
                                     1,
                                     statistics)
        
        @test best_solution.objective == 72
        @test best_solution.bucket == [1,1,1,2,2,3]
        
    end
    =#

end