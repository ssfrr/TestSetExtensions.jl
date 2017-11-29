using TestSetExtensions
using Suppressor

using Compat.Test

orig_color = Base.have_color

eval(Base, :(have_color = true))
output_color = @capture_out begin
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

eval(Base, :(have_color = false))
output_nocolor = @capture_out begin
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

eval(Base, :(have_color = $orig_color))


try
    info("You should see 3 failing tests with pretty diffs...")
    include(joinpath("..", "diffdemo.jl"))
catch
end
try
    info("These 4 failing tests don't have pretty diffs to display")
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
    @testset "check output" begin
        if VERSION <= v"0.6.0-"
            @test split(output_color, '\n')[1] == "\e[1m\e[32m.\e[0m\e[1m\e[32m.\e[0m\e[1m\e[32m.\e[0m\e[1m\e[32m.\e[0m"
        else
            @test split(output_color, '\n')[1] == "\e[32m.\e[39m\e[32m.\e[39m\e[32m.\e[39m\e[32m.\e[39m"
        end
        @test split(output_nocolor, '\n')[1] == "...."
    end


    @testset "DottedTestSet is deprecated" begin
        @test_warn "DottedTestSet is deprecated, use ExtendedTestSet instead." @testset DottedTestSet "testing" begin
            @test true
        end
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
        ex = macroexpand(:(@includetests one two))
        @test ex.head == :error
    end
end
