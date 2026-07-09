@testitem "ReTestItems" begin
    using TestSetExtensions: ExtendedTestSet
    @testset ExtendedTestSet "ReTestItems compatibility" begin
        @test true
    end
end
