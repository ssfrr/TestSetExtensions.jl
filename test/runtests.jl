using Test
using Test: DefaultTestSet
using TestSetExtensions
using Aqua
using MetaTesting
using Logging
using Suppressor
using TestReports
using EzXML

using MetaTesting: EncasedTestSet

@testset ExtendedTestSet "TextSetExtensions Tests" begin
    @testset "Aqua" begin
        Aqua.test_all(TestSetExtensions)
    end
    @testset "progress" begin
        include("progress.jl")
    end
    @testset "display.jl" begin
        include("display.jl")
    end
    @testset "diff" begin
        include("diff.jl")
    end
    @testset "no diff" begin
        include("no_diff.jl")
    end

    @testset "TestReports" begin
        ts = @testset ExtendedTestSet "Nested" begin
            record_testset_property("nested", "pass")
            @testset ExtendedTestSet "Matroska 1" begin
                record_testset_property("matroska 1", "pass")
                @testset ExtendedTestSet "Matroska 2" begin
                    record_testset_property("matroska 2", "pass")
                end
            end
        end

        xml = report(ts)
        @test length(collect(eachnode(root(xml)))) == 3
    end
end

# Regression test for Julia < 1.12: plain @testset nested inside an ExtendedTestSet
# inherits the parent's type, producing ExtendedTestSet children that Julia 1.10's
# get_test_counts (which checks isa(t, DefaultTestSet)) silently skips, showing "None 0.0s".
let output = @capture_out begin
    @testset ExtendedTestSet "result propagation" begin
        @testset "nested" begin
            @test true
        end
    end
end
    @testset "ExtendedTestSet result propagation" begin
        @test occursin("Pass", output)
        @test !occursin("None", output)
    end
end
