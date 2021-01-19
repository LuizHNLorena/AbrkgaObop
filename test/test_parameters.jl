@testset "Testing parameters.jl" begin

    @testset "Testing parameters creation and update" begin

        # Create
        parameters = AbrkgaObop.OBOPParameters(0.99)

        @test parameters.gama == 0.99
        @test parameters.max_generations == 137
        @test parameters.population_size == 100
        @test parameters.elite_size == 10
        @test parameters.mutation_size == 20

        # Update
        AbrkgaObop.update_parameters!(100,parameters)

        @test parameters.max_generations == 137
        @test parameters.population_size == 99
        @test parameters.elite_size == 21
        @test parameters.mutation_size == 9
    end;

end