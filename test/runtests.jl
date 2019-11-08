using Test, TestSetExtensions
using Logging
using Suppressor

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

try
    @info "You should see 3 failing tests with pretty diffs..."
    include(joinpath("..", "diffdemo.jl"))
catch
end
try
    @info "These 4 failing tests don't have pretty diffs to display"
    @testset ExtendedTestSet "not-pretty" begin
        @testset "No pretty diff for matrices" begin
            @test [1 2; 3 4] == [1 4; 3 4]
        end
        @testset "don't diff non-equality" begin
            @test 1 > 2
        end
        @testset "don't diff non-comparisons" begin
            @test iseven(7)
        end
        @testset "errors don't have diffs either" begin
            throw(ErrorException("This test is supposed to throw an error"))
        end
    end
catch
end

@testset ExtendedTestSet "TextSetExtensions Tests" begin
    @testset "check output dots" begin
        @test split(output, '\n')[1] == "...."
    end

    @testset "Auto-run test files" begin
        global file1_run = false
        global file2_run = false
        global file3_run = false

        @includetests

        @test file1_run
        @test file2_run
        @test file3_run
    end

    @testset "run selected test files" begin
        global file1_run = false
        global file2_run = false
        global file3_run = false

        @includetests ["file1", "file3"]

        @test file1_run
        @test !file2_run
        @test file3_run
    end

    @testset "more than one arg to @includetests is an error" begin
        @test_throws LoadError macroexpand(@__MODULE__, :(@includetests one two))
    end
end
