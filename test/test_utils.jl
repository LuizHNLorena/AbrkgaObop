@testset "Testing utils.jl" begin
    
    bucket = [1,2,3,4,5,6]
    @test AbrkgaObop.create_bucket_order(bucket) == " 1 | 2 | 3 | 4 | 5 | 6 "
    
    bucket = [1,1,1,1,1,1]
    @test AbrkgaObop.create_bucket_order(bucket) == " 1 , 2 , 3 , 4 , 5 , 6 "
    
    bucket = [1,1,1,2,2,3]
    @test AbrkgaObop.create_bucket_order(bucket) == " 1 , 2 , 3 | 4 , 5 | 6 "
    
    bucket = [1,2,3,2,1,1]
    @test AbrkgaObop.create_bucket_order(bucket) == " 1 , 5 , 6 | 2 , 4 | 3 "

end