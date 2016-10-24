@testset "file2 gets run" begin
    global file2_run
    @test !file2_run
    file2_run = true
    @test file2_run
end
