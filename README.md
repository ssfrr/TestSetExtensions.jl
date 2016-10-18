# DottedTestSets

[![Build Status](https://travis-ci.org/ssfrr/DottedTestSets.jl.svg?branch=master)](https://travis-ci.org/ssfrr/DottedTestSets.jl)

[![Coverage Status](https://coveralls.io/repos/ssfrr/DottedTestSets.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/ssfrr/DottedTestSets.jl?branch=master)

[![codecov.io](http://codecov.io/github/ssfrr/DottedTestSets.jl/coverage.svg?branch=master)](http://codecov.io/github/ssfrr/DottedTestSets.jl?branch=master)

![DottedTestSets example gif](http://ssfrr.github.io/DottedTestSets.jl/DottedTestSet.gif)

This is a simple package to output green dots as your tests pass, so you can have a sense of progress. To use it, simply add `DottedTestSet` as a custom testset type to your top-level `@testset`, and then use Base.Test as usual. All nested testsets will use it as well. Note that for 0.4 compatibility you'll need to use the [BaseTestNext.jl](https://github.com/JuliaCI/BaseTestNext.jl) package.

```julia
using Base.Test
using DottedTestSets

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
```
