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

@testset ExtendedTestSet "TestSetExtensions Tests" begin
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

@info "ExtendedTestSet{FallbackTestSet} test sets should exit when the first test fails"
@testset "ExtendedTestSet{FallbackTestSet} Tests" begin
    ets_fallback = ExtendedTestSet{Test.FallbackTestSet}

    # Single-level test set
    err = nothing
    try
        @testset ets_fallback "top-level tests" begin
            @test 1 == 2
            @test 1 == 1
        end
    catch err
    end

    @test err isa TestSetExtensions.ExtendedTestSetException
    @test err.msg == "FallbackTestSetException occurred"

    # Nested test sets
    err = nothing
    try
        @testset ets_fallback "top-level tests" begin
            @testset "Test set with failing test" begin
                @test 1 == 2
                @test 1 == 1
            end
            @testset "Test set with no failing tests" begin
                @test 2 == 2
                @test 3 == 3
            end
        end
    catch err
    end

    @test err isa TestSetExtensions.ExtendedTestSetException
    @test err.msg == "FallbackTestSetException occurred"

    # --- Nested DefaultTestSet tests
    #
    # * Tests Test.record(ExtendedTestSet{FallbackTestSet}, DefaultTestSet) needed for
    #   backward compatibility with Julia<=1.3.

    default_test_set = Test.DefaultTestSet

    # ------ DefaultTest nested under single ExtendedTestSet{FallbackTestSet} test set

    # With failing tests
    err = nothing
    try
        @testset ets_fallback "top-level tests" begin
            @testset default_test_set "Failing test" begin
                @test 1 == 2
                @test 1 == 1
            end
            @testset default_test_set "No failing tests" begin
                @test 2 == 2
                @test 3 == 3
            end
        end
    catch err
    end

    @test err isa Test.FallbackTestSetException

    # With no failing tests
    err = nothing
    try
        @testset ets_fallback "top-level tests" begin
            @testset default_test_set "No failing tests" begin
                @test 2 == 2
                @test 3 == 3
            end
        end
    catch err
    end

    @test isnothing(err)

    # ------ DefaultTest nested under multiple ExtendedTestSet{FallbackTestSet} test sets

    # With failing tests
    try
        @testset ets_fallback "top-level tests" begin
            @testset ets_fallback "2nd-level tests" begin
                @testset default_test_set "Failing test" begin
                    @test 1 == 2
                    @test 1 == 1
                end
                @testset default_test_set "No failing tests" begin
                    @test 2 == 2
                    @test 3 == 3
                end
            end
        end
    catch err
    end

    @test err isa TestSetExtensions.ExtendedTestSetException
    @test err.msg == "FallbackTestSetException occurred"

    # With no failing tests
    err = nothing
    try
        @testset ets_fallback "top-level tests" begin
            @testset ets_fallback "2nd-level tests" begin
                @testset default_test_set "No failing tests" begin
                    @test 2 == 2
                    @test 3 == 3
                end
            end
        end
    catch err
    end

    @test isnothing(err)
end
