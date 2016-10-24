@testset "file3 gets run" begin
    global file3_run
    @test !file3_run
    file3_run = true
    @test file3_run
end
