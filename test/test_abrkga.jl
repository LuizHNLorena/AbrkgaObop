@testset "Testing abrkga.jl" begin

    @testset "Testing abrkga.jl with toi file" begin
        instance = read_dataset("datasets/movie.toi")
        objective, bucket_order, statistics = execute(instance,seed=0,local_search=true)

        @test objective == 72
        @test bucket_order == " 1 | 2 , 3 | 4 | 5 , 6 "
        @test statistics.time_best < statistics.time_total

    end;

end