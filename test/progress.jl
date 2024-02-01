@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        @testset ExtendedTestSet "top-level tests" begin
            @testset "2nd-level tests 1" begin
                @test true
                @test 1 == 1
            end
            @testset "2nd-level tests 2" begin
                @test true
                @test 1 == 1
            end
        end
    end
end

@testset "check output dots" begin
    @test split(output, '\n')[1] == "...."
end
