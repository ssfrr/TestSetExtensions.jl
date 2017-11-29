# TestSetExtensions

[![Build Status](https://travis-ci.org/ssfrr/TestSetExtensions.jl.svg?branch=master)](https://travis-ci.org/ssfrr/TestSetExtensions.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/79m2ru7o3upt86ds/branch/master?svg=true)](https://ci.appveyor.com/project/ssfrr/testsetextensions-jl/branch/master)
[![codecov.io](http://codecov.io/github/ssfrr/TestSetExtensions.jl/coverage.svg?branch=master)](http://codecov.io/github/ssfrr/TestSetExtensions.jl?branch=master)

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

## `@includetests`
TestSetExtensions also provides a `@includetests` macro that makes it easy to selectively run your tests, for cases when your full test suite is large and you only need to run a subset of your tests to test a feature you're working on. The macro takes a list of test files, so you can pass it `ARGS` to allow the user to specify which tests to run from the command line.

```julia
using Compat.Test
using TestSetExtensions

@testset "All the tests" begin
    @includetests ARGS
end
```

If the user doesn't provide any command-line arguments, this will look for any `*.jl` files in the same directory as the running file (usually `runtests.jl`) and `include` them. The user can also specify a list of test files:

```
$ julia test/runtests.jl footests bartests
```

Which will run `footests.jl` and `bartests.jl`.

`@includetests` will print out each test module name as it goes (here in combination with `ExtendedTestSet`):

![includetests output](http://ssfrr.github.io/TestSetExtensions.jl/includetests.png)
