# TestSetExtensions

[![CI](https://github.com/palday/TestSetExtensions.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/palday/TestSetExtensions.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/palday/TestSetExtensions.jl/graph/badge.svg?token=OFJ613ESY8)](https://codecov.io/gh/palday/TestSetExtensions.jl)

![TestSetExtensions example gif](http://ssfrr.github.io/TestSetExtensions.jl/ExtendedTestSet.gif)

This package collects some extensions and convenience utilities to maximize your testing enjoyment. It builds on the new `Test` infrastructure in Julia v0.5 (also available in v0.4 with the `BaseTestNext` package). It's designed so that you shouldn't need to modify your tests at all if you're already using `@testset` and `@test` - all the interactions with this package happen at the top-level of your tests.

## `ExtendedTestSet`

The `ExtendedTestSet` type makes your test output more readable. It outputs green dots as your tests pass, so you can have a sense of progress. It also displays diffs on test failure using the [`DeepDiffs`](https://github.com/ssfrr/DeepDiffs.jl) package. To use it, simply add `ExtendedTestSet` as a custom testset type to your top-level `@testset`, and then use `Test` functions as usual. All nested testsets will use it automatically.

```julia
using Compat.Test
using TestSetExtensions

@testset ExtendedTestSet "All the tests" begin
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

### Diff output example

![After diff output](http://ssfrr.github.io/TestSetExtensions.jl/diff_after.png)
