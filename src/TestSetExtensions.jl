module TestSetExtensions

export ExtendedTestSet, @includetests

using Compat.Test
import Compat.Test: record, finish
using Compat.Test: DefaultTestSet, AbstractTestSet
using Compat.Test: get_testset_depth, scrub_backtrace
using Compat.Test: Result, Pass, Fail, Error

using Base: @deprecate
@deprecate DottedTestSet ExtendedTestSet

using DeepDiffs

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
            tests = filter(f->endswith(f, ".jl") && f!= basename(rootfile), tests)
        else
            tests = map(f->string(f, ".jl"), tests)
        end
        println();
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
        print_with_color(:white, ts.wrapped.description, ": ")
        if res.test_type == :test && isa(res.data,Expr) && res.data.head == :comparison
            dd = deepdiff(res.data.args[1], res.data.args[3])
            if !isa(dd, DeepDiffs.SimpleDiff)
                # The test was an comparison between things we can diff,
                # so display the diff
                print_with_color(Base.error_color(), "Test Failed\n"; bold = true)
                println("  Expression: ", res.orig_expr)
                print_with_color(Base.info_color(), "\nDiff:\n")
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
        Base.show_backtrace(STDOUT, scrub_backtrace(backtrace()))
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
    print_with_color(:green, ".")
    record(ts.wrapped, res)
    res
end

record(ts::ExtendedTestSet, res) = record(ts.wrapped, res)

function finish(ts::ExtendedTestSet)
    get_testset_depth() == 0 && print("\n\n")
    finish(ts.wrapped)
end

end # module
