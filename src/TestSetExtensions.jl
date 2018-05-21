module TestSetExtensions

export ExtendedTestSet, @includetests

using DeepDiffs

using Compat
using Compat.Distributed
using Compat.Test
using Compat.Test: DefaultTestSet, AbstractTestSet,
                   get_testset_depth, scrub_backtrace,
                   Result, Pass, Fail, Error
import Compat.Test: record, finish

Base.@deprecate_binding DottedTestSet ExtendedTestSet

"""
Includes the given test files, given as a list without their ".jl" extensions.
If none are given it will scan the directory of the calling file and include all
the julia files.
"""
macro includetests(testarg...)
    if length(testarg) == 0
        tests = []
    elseif length(testarg) == 1
        tests = testarg[1]
    else
        error("@includetests takes zero or one argument")
    end

    quote
        tests = $tests
        rootfile = @__FILE__
        if length(tests) == 0
            tests = readdir(dirname(rootfile))
            tests = filter(f->endswith(f, ".jl") && f != basename(rootfile), tests)
        else
            tests = map(f->string(f, ".jl"), tests)
        end
        println()
        for test in tests
            print(splitext(test)[1], ": ")
            include(test)
            println()
        end
    end
end

struct ExtendedTestSet{T<:AbstractTestSet} <: AbstractTestSet
    wrapped::T

    ExtendedTestSet{T}(desc) where {T} = new(T(desc))
end

struct FailDiff <: Result
    result::Fail
end

function ExtendedTestSet(desc; wrap=DefaultTestSet)
    ExtendedTestSet{wrap}(desc)
end

function record(ts::ExtendedTestSet, res::Fail)
    if myid() == 1
        println("\n=====================================================")
        printstyled(ts.wrapped.description, ": ", color=:white)
        if res.test_type == :test && isa(res.data,Expr) && res.data.head == :comparison
            dd = deepdiff(res.data.args[1], res.data.args[3])
            if !isa(dd, DeepDiffs.SimpleDiff)
                # The test was an comparison between things we can diff,
                # so display the diff
                printstyled("Test Failed\n", bold=true, color=Base.error_color())
                println("  Expression: ", res.orig_expr)
                printstyled("\nDiff:\n", color=Base.info_color())
                display(dd)
                println()
            else
                # fallback to the default printing if we don't have a pretty diff
                print(res)
            end
        else
            # fallback to the default printing for non-comparisons
            print(res)
        end
        Base.show_backtrace(stdout, scrub_backtrace(backtrace()))
        # show_backtrace doesn't print a trailing newline
        println("\n=====================================================")
    end
    push!(ts.wrapped.results, res)
    res, backtrace()
end

function record(ts::ExtendedTestSet, res::Error)
    println("\n=====================================================")
    record(ts.wrapped, res)
    print("=====================================================\n")
end

function record(ts::ExtendedTestSet, res::Pass)
    printstyled(".", color=:green)
    record(ts.wrapped, res)
    res
end

record(ts::ExtendedTestSet, res) = record(ts.wrapped, res)

function finish(ts::ExtendedTestSet)
    get_testset_depth() == 0 && print("\n\n")
    finish(ts.wrapped)
end

end # module
