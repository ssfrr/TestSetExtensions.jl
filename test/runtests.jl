using Test
using TestSetExtensions
using Aqua
using MetaTesting
using Logging
using Suppressor

using MetaTesting: EncasedTestSet

@testset ExtendedTestSet "TextSetExtensions Tests" begin
    @testset "Aqua" begin
        Aqua.test_all(TestSetExtensions)
    end
    @testset "progress" begin
        include("progress.jl")
    end
    @testset "diff" begin
        include("diff.jl")
    end
    @testset "no diff" begin
        include("no_diff.jl")
    end
end
