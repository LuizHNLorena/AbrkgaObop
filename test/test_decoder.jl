@testset "Testing decoder.jl" begin

    @testset "Testing decoder and objective" begin
        instance = read_dataset("datasets/movie.toi");
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
        
        # Test decoder
        AbrkgaObop.decoder!(1,bucket,keys)
        @test bucket[:,1] == [1,2,3,4,5,6]
        AbrkgaObop.decoder!(2,bucket,keys)
        @test bucket[:,2] == [1,2,3,4,5,6]

        # Test objective
        fitness=[0,0]
        AbrkgaObop.objective!(1,bucket,fitness,instance)
        AbrkgaObop.objective!(2,bucket,fitness,instance)
        @test fitness[1] == fitness[2]
    end;
    
end