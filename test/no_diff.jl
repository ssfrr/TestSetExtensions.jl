@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "higher dimensional arrays" begin
                @test [1 2; 3 4; 5 6] == [1 4; 3 4; 5 6]
             end
        catch
        end
    end
end
# XXX this should be updated when DeepDiffs.jl uses semmicolon instead of comma for matrix diff
@test contains(output, "Diff:\n[(-)1 2, (+)1 4, 3 4, 5 6]")

@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "inequality" begin
                @test 1 > 2
             end
        catch
        end
    end
end
@test !contains(output, "Diff:")


@testset EncasedTestSet "wrapper" begin
    global output
        output = @capture_out begin
        try
            @testset ExtendedTestSet "noncomparisons" begin
                @test iseven(7)
             end
        catch
        end
    end
end
@test !contains(output, "Diff:")

@testset EncasedTestSet "wrapper" begin
        global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "errors" begin
                throw(ErrorException("This test is supposed to throw an error"))
             end
        catch
        end
    end
end
@test !contains(output, "Diff:")
