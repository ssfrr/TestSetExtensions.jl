# TestSetExtensions

[![Build Status](https://travis-ci.org/ssfrr/TestSetExtensions.jl.svg?branch=master)](https://travis-ci.org/ssfrr/TestSetExtensions.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/79m2ru7o3upt86ds/branch/master?svg=true)](https://ci.appveyor.com/project/ssfrr/testsetextensions-jl/branch/master)
[![codecov.io](http://codecov.io/github/ssfrr/TestSetExtensions.jl/coverage.svg?branch=master)](http://codecov.io/github/ssfrr/TestSetExtensions.jl?branch=master)

![TestSetExtensions example gif](http://ssfrr.github.io/TestSetExtensions.jl/DottedTestSet.gif)

This package collects some extensions and convenience utilities to maximize your testing enjoyment. It builds on the new `Base.Test` infrastructure in Julia v0.5 (also available in v0.4 with the `BaseTestNext` package).

## `DottedTestSet`

This is a simple TestSet type that outputs green dots as your tests pass, so you can have a sense of progress. To use it, simply add `DottedTestSet` as a custom testset type to your top-level `@testset`, and then use `Base.Test` as usual. All nested testsets will use it as well.

```julia
using Base.Test
using TestSetExtensions

@testset DottedTestSet "All the tests" begin
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

## `@includetests`
TestSetExtensions also provides a `@includetests` macro that makes it easy to selectively run your tests, for cases when your full test suite is large and you only need to run a subset of your tests to test a feature you're working on. The macro takes a list of test files, so you can pass it `ARGS` to allow the user to specify which tests to run from the command line.

```julia
using Base.Test
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

`@includetests` will print out each test module name as it goes:

![includetests output](http://ssfrr.github.io/TestSetExtensions.jl/includetests.png)
