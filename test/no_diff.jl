@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "matrices" begin
                @test [1 2; 3 4] == [1 4; 3 4]
             end
        catch
        end
    end
end
@test contains(output, "Diff:\nnothing")

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
