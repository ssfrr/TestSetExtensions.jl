@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "vectors" begin
                @test [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]
            end
        catch
        end
    end
end
@test contains(output, "Diff:\n[3, 5, 6, 1, (-)6, (+)9, 8]")

@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "strings" begin
                @test """Lorem ipsum dolor sit amet,
                         consectetur adipiscing elit, sed do
                         eiusmod tempor incididunt ut
                         labore et dolore magna aliqua.
                         Ut enim ad minim veniam, quis nostrud
                         exercitation ullamco aboris.""" ==
                      """Lorem ipsum dolor sit amet,
                         consectetur adipiscing elit, sed do
                         eiusmod temper incididunt ut
                         labore et dolore magna aliqua.
                         Ut enim ad minim veniam, quis nostrud
                         exercitation ullamco aboris."""
            end
        catch
        end
    end
end
@test contains(output, """Diff:
\"\"\"
  Lorem ipsum dolor sit amet,
  consectetur adipiscing elit, sed do
- eiusmod tempor incididunt ut
+ eiusmod temper incididunt ut
  labore et dolore magna aliqua.
  Ut enim ad minim veniam, quis nostrud
  exercitation ullamco aboris.\"\"\"""")

@testset EncasedTestSet "wrapper" begin
    global output
    output = @capture_out begin
        try
            @testset ExtendedTestSet "dicts" begin
                @test Dict(:foo => "bar", :baz => [1, 4, 5], :biz => nothing) ==
                       Dict(:baz => [1, 7, 5], :biz => 42)
            end
        catch
        end
    end
end

@test contains(output,
               """Diff:\n[Dict{Symbol, Any}, (-):biz => nothing, (-):baz => [1, 4, 5], (-):foo => "bar", (+):biz => 42, (+):baz => [1, 7, 5]]""")
