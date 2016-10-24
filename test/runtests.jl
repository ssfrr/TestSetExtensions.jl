using TestSetExtensions
using Suppressor

if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
end

orig_color = Base.have_color

eval(Base, :(have_color = true))
output_color = @capture_out begin
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

eval(Base, :(have_color = false))
output_nocolor = @capture_out begin
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

eval(Base, :(have_color = $orig_color))

@testset DottedTestSet "TextSetExtensions Tests" begin
    @testset "check output" begin
        @test output_color ==
            """\e[1m\e[32m.\e[0m\e[1m\e[32m.\e[0m\e[1m\e[32m.\e[0m\e[1m\e[32m.\e[0m

            \e[1m\e[37mTest Summary:   | \e[0m\e[1m\e[32mPass  \e[0m\e[1m\e[34mTotal\e[0m
              top-level tests | \e[1m\e[32m   4  \e[0m\e[1m\e[34m    4\e[0m
            """

        @test output_nocolor ==
            """
            ....

            Test Summary:   | Pass  Total
              top-level tests |    4      4
            """
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
end
