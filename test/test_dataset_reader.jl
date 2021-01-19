@testset "Testing read_dataset.jl" begin

    @testset "Reading matrix file" begin
        instance = read_dataset("datasets/movie.dat",cost_matrix = true)
        @test instance.file_name == "datasets/movie.dat"
        @test instance.total_itens == 10
        @test instance.total_voters == 0
        @test instance.interval_init == [i * (1/10) for i in 0:9]
        @test size(instance.item_names) == (10,)
        @test instance.item_names == string.(collect(1:10))
        @test size(instance.C) == (10,10)
        @test instance.C == [0   3   3   5   5   5   5   5   5  5;
                            3   0   5   5   5   5   5   5   5  5;
                            -1   1   0   1   3   5   3   5   5  5;
                            1  -1   1   0   5   5   5   5   5  5;
                            -5  -5  -1  -1   0   5   5   5   5  5;
                            -5  -5  -3  -5  -5   0  -5   5   5  5;
                            -5  -5  -1  -3   3   5   0   5   5  5;
                            -5  -5  -5  -5  -5   3  -5   0   5  5;
                            -5  -5  -5  -5  -5  -1  -5  -1   0  5;
                            -5  -5  -5  -5  -5  -5  -5  -5  -1  0]
        @test size(instance.D) == (10,10)
        @test instance.D == [0    0     4    4   10   10   10   10  10  10;
                            0    0     4    6   10   10   10   10  10  10;
                            -4   -4     0    0    4    8    4   10  10  10;
                            -4   -6     0    0    6   10    8   10  10  10;
                            -10  -10   -4   -6    0   10    2   10  10  10;
                            -10  -10   -8  -10  -10    0  -10    2   6  10;
                            -10  -10   -4   -8   -2   10    0   10  10  10;
                            -10  -10  -10  -10  -10   -2  -10    0   6  10;
                            -10  -10  -10  -10  -10   -6  -10   -6   0   6;
                            -10  -10  -10  -10  -10  -10  -10  -10  -6   0]
    end;

    @testset "Reading soc file" begin
        instance = read_dataset("datasets/movie.soc")
        @test instance.file_name == "datasets/movie.soc"
        @test instance.total_itens == 10
        @test instance.total_voters == 5
        @test instance.interval_init == [i * (1/10) for i in 0:9]
        @test size(instance.item_names) == (10,)
        @test instance.item_names == ["The Shawshank Redemption (1994)", 
                                      "The Godfather (1972)", 
                                      "The Godfather: Part II (1974)", 
                                      "Schindler's List (1993)", 
                                      "Pulp Fiction (1994)", 
                                      "Rocky (1976)", 
                                      "Her (2013)", 
                                      "Mission: Impossible II (2000)", 
                                      "Cats (2019)", 
                                      "Disaster Movie (2008)"]
        @test size(instance.C) == (10,10)
        @test instance.C == [0   3   3   5   5   5   5   5   5  5;
                            -3   0   5   5   5   5   5   5   5  5;
                            -3  -5   0   1   3   5   3   5   5  5;
                            -5  -5  -1   0   5   5   5   5   5  5;
                            -5  -5  -3  -5   0   5   5   5   5  5;
                            -5  -5  -5  -5  -5   0  -5   5   5  5;
                            -5  -5  -3  -5  -5   5   0   5   5  5;
                            -5  -5  -5  -5  -5  -5  -5   0   5  5;
                            -5  -5  -5  -5  -5  -5  -5  -5   0  5;
                            -5  -5  -5  -5  -5  -5  -5  -5  -5  0]
        @test size(instance.D) == (10,10)
        @test instance.D == [0    6    6   10   10   10   10   10   10  10;
                            -6    0   10   10   10   10   10   10   10  10;
                            -6  -10    0    2    6   10    6   10   10  10;
                           -10  -10   -2    0   10   10   10   10   10  10;
                           -10  -10   -6  -10    0   10   10   10   10  10;
                           -10  -10  -10  -10  -10    0  -10   10   10  10;
                           -10  -10   -6  -10  -10   10    0   10   10  10;
                           -10  -10  -10  -10  -10  -10  -10    0   10  10;
                           -10  -10  -10  -10  -10  -10  -10  -10    0  10;
                           -10  -10  -10  -10  -10  -10  -10  -10  -10   0]
    end;

    @testset "Reading soi file" begin
        instance = read_dataset("datasets/movie.soi")
        @test instance.file_name == "datasets/movie.soi"
        @test instance.total_itens == 10
        @test instance.total_voters == 5
        @test instance.interval_init == [i * (1/10) for i in 0:9]
        @test size(instance.item_names) == (10,)
        @test instance.item_names == ["The Shawshank Redemption (1994)", 
                                      "The Godfather (1972)", 
                                      "The Godfather: Part II (1974)", 
                                      "Schindler's List (1993)", 
                                      "Pulp Fiction (1994)", 
                                      "Rocky (1976)", 
                                      "Her (2013)", 
                                      "Mission: Impossible II (2000)", 
                                      "Cats (2019)", 
                                      "Disaster Movie (2008)"]
        @test size(instance.C) == (10,10)
        @test instance.C == [0   3   4   3   2   3   4   3   3  3;
                            -3   0   4   2   2   4   3   4   3  3;
                            -4  -4   0  -1   2   4   2   4   4  4;
                            -3  -2   1   0   2   2   3   2   2  2;
                            -2  -2  -2  -2   0   2   2   2   1  1;
                            -3  -4  -4  -2  -2   0  -3   4   3  3;
                            -4  -3  -2  -3  -2   3   0   3   3  3;
                            -3  -4  -4  -2  -2  -4  -3   0   3  3;
                            -3  -3  -4  -2  -1  -3  -3  -3   0  4;
                            -3  -3  -4  -2  -1  -3  -3  -3  -4  0]
        @test size(instance.D) == (10,10)
        @test instance.D == [0   6   8   6   4   6   8   6   6  6
                            -6   0   8   4   4   8   6   8   6  6
                            -8  -8   0  -2   4   8   4   8   8  8
                            -6  -4   2   0   4   4   6   4   4  4
                            -4  -4  -4  -4   0   4   4   4   2  2
                            -6  -8  -8  -4  -4   0  -6   8   6  6
                            -8  -6  -4  -6  -4   6   0   6   6  6
                            -6  -8  -8  -4  -4  -8  -6   0   6  6
                            -6  -6  -8  -4  -2  -6  -6  -6   0  8
                            -6  -6  -8  -4  -2  -6  -6  -6  -8  0]
    end;

    @testset "Reading toc file" begin
        instance = read_dataset("datasets/movie.toc")
        @test instance.file_name == "datasets/movie.toc"
        @test instance.total_itens == 10
        @test instance.total_voters == 5
        @test instance.interval_init == [i * (1/10) for i in 0:9]
        @test size(instance.item_names) == (10,)
        @test instance.item_names == ["The Shawshank Redemption (1994)", 
                                    "The Godfather (1972)", 
                                    "The Godfather: Part II (1974)", 
                                    "Schindler's List (1993)", 
                                    "Pulp Fiction (1994)", 
                                    "Rocky (1976)", 
                                    "Her (2013)", 
                                    "Mission: Impossible II (2000)", 
                                    "Cats (2019)", 
                                    "Disaster Movie (2008)"]
        @test size(instance.C) == (10,10)
        @test instance.C == [0   3   3   5   5   5   5   5   5  5;
                            3   0   5   5   5   5   5   5   5  5;
                            -1   1   0   1   3   5   3   5   5  5;
                            1  -1   1   0   5   5   5   5   5  5;
                            -5  -5  -1  -1   0   5   5   5   5  5;
                            -5  -5  -3  -5  -5   0  -5   5   5  5;
                            -5  -5  -1  -3   3   5   0   5   5  5;
                            -5  -5  -5  -5  -5   3  -5   0   5  5;
                            -5  -5  -5  -5  -5  -1  -5  -1   0  5;
                            -5  -5  -5  -5  -5  -5  -5  -5  -1  0]
        @test size(instance.D) == (10,10)
        @test instance.D == [0    0     4    4   10   10   10   10  10  10;
                            0    0     4    6   10   10   10   10  10  10;
                            -4   -4     0    0    4    8    4   10  10  10;
                            -4   -6     0    0    6   10    8   10  10  10;
                            -10  -10   -4   -6    0   10    2   10  10  10;
                            -10  -10   -8  -10  -10    0  -10    2   6  10;
                            -10  -10   -4   -8   -2   10    0   10  10  10;
                            -10  -10  -10  -10  -10   -2  -10    0   6  10;
                            -10  -10  -10  -10  -10   -6  -10   -6   0   6;
                            -10  -10  -10  -10  -10  -10  -10  -10  -6   0]
    end;

    @testset "Reading toi file" begin
        instance = read_dataset("datasets/movie.toi")
        @test instance.file_name == "datasets/movie.toi"
        @test instance.total_itens == 6
        @test instance.total_voters == 5
        @test instance.interval_init == [i * (1/6) for i in 0:5]
        @test size(instance.item_names) == (6,)
        @test instance.item_names == ["The Shawshank Redemption (1994)",
                                    "The Godfather (1972)",
                                    "Schindler's List (1993)",
                                    "Pulp Fiction (1994)",
                                    "Rocky (1976)",
                                    "Cats (2019)"]
        @test size(instance.C) == (6,6)
        @test instance.C == [0   2   2   4  2  3;
                            2   0   2   5  3  3;
                            0   2   0   4  2  3;
                            -2  -5  -2   0  1  3;
                            -2  -3  -2   1  0  1;
                            -3  -3  -3  -3  1  0]
        @test size(instance.D) == (6,6)
        @test instance.D == [ 0    0   2   6  4  6;
                            0    0   0  10  6  6;
                            -2    0   0   6  4  6;
                            -6  -10  -6   0  0  6;
                            -4   -6  -4   0  0  0;
                            -6   -6  -6  -6  0  0]
    end;

end;