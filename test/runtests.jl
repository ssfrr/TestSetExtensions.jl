using Test
using TestSetExtensions
using MetaTesting
using Logging
using Suppressor

using MetaTesting: EncasedTestSet

@testset ExtendedTestSet "TextSetExtensions Tests" begin
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
