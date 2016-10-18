using DottedTestSets
using Suppressor

if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
end

output = @capture_out begin
    @testset DottedTestSet "top-level tests" begin
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

@testset "check output" begin
    @test output == """
....

Test Summary:   | Pass  Total
  top-level tests |    4      4\n"""
end
