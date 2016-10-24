@testset "file1 gets run" begin
    global file1_run
    @test !file1_run
    file1_run = true
    @test file1_run
end
