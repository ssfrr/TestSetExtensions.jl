global ets_out
global dts_out

const ETS = ExtendedTestSet{Test.DefaultTestSet}

function nested_tests()
    @testset "2nd-level tests 1" begin
        @test true
        @test 1 == 1
    end
    @testset "2nd-level tests 2" begin
        @test true
        @test 1 == 1
    end
end

@testset EncasedTestSet "wrapper" begin
    ets = @testset ETS "testset" begin
        nested_tests()
    end

    dts = @testset Test.DefaultTestSet "testset" begin
        nested_tests()
    end

    global ets_out = @capture_out Test.print_test_results(ets)
    global dts_out = @capture_out Test.print_test_results(dts)
end

# unify timing info
ets_out = strip(replace(ets_out, r"[0-9]\.[0-9]s" => ""))
dts_out = strip(replace(dts_out, r"[0-9]\.[0-9]s" => ""))

@test ets_out == dts_out
