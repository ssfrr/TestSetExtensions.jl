module TestSetExtensions

using Distributed, Test, DeepDiffs
using Test: AbstractTestSet, DefaultTestSet, FallbackTestSet
using Test: Result, Fail, Error, Pass
export ExtendedTestSet, @includetests

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

    rootfile = "$(__source__.file)"
    mod = __module__

    quote
        tests = $tests
        rootfile = $rootfile

        if length(tests) == 0
            tests = readdir(dirname(rootfile))
            tests = filter(f->endswith(f, ".jl") && f!= basename(rootfile), tests)
        else
            tests = map(f->string(f, ".jl"), tests)
        end

        println();

        for test in tests
            print(splitext(test)[1], ": ")
            Base.include($mod, test)
            println()
        end
    end
end

struct ExtendedTestSet{T<:AbstractTestSet} <: AbstractTestSet
    wrapped::T

    ExtendedTestSet{T}(desc) where {T} = new(T(desc))
    ExtendedTestSet{FallbackTestSet}(desc) = new(FallbackTestSet())
end

struct FailDiff <: Result
    result::Fail
end

struct ExtendedTestSetException <: Exception
    msg::AbstractString
end

function ExtendedTestSet(desc; wrap=DefaultTestSet)
    ExtendedTestSet{wrap}(desc)
end

function Test.record(ts::ExtendedTestSet{T}, res::Fail) where {T}
    println("\n=====================================================")
    Test.record(ts.wrapped, res)
    print("=====================================================\n")
end

function Test.record(ts::ExtendedTestSet{DefaultTestSet}, res::Fail)
    if Distributed.myid() == 1
        println("\n=====================================================")
        printstyled(ts.wrapped.description, ": "; color = :white)

        if res.test_type === :test
            try
                test_expr = if isa(res.data, Expr)
                    res.data
                elseif isa(res.data, String)
                    Meta.parse(res.data)
                end

                if test_expr.head === :call && test_expr.args[1] === Symbol("==")
                    dd = if isa(test_expr.args[2], String) && isa(test_expr.args[3], String)
                        deepdiff(test_expr.args[2], test_expr.args[3])
                    elseif test_expr.args[2].head === :vect && test_expr.args[3].head === :vect
                        deepdiff(test_expr.args[2].args, test_expr.args[3].args)
                    elseif test_expr.args[2].head === :call && test_expr.args[3].head === :call &&
                            test_expr.args[2].args[1].head === :curly && test_expr.args[3].args[1].head === :curly
                        deepdiff(Base.eval(test_expr.args[2].args), Base.eval(test_expr.args[3].args))
                    end

                    if ! isa(dd, DeepDiffs.SimpleDiff)
                        # The test was an comparison between things we can diff,
                        # so display the diff
                        printstyled("Test Failed\n"; bold = true, color = Base.error_color())
                        println("  Expression: ", res.orig_expr)
                        printstyled("\nDiff:\n"; color = Base.info_color())
                        display(dd)
                        println()
                    else
                        # fallback to the default printing if we don't have a pretty diff
                        print(res)
                    end
                end
            catch ex
                print(res)
            end
        else
            # fallback to the default printing for non-comparisons
            print(res)
        end

        Base.show_backtrace(stdout, Test.scrub_backtrace(backtrace()))
        # show_backtrace doesn't print a trailing newline
        println("\n=====================================================")
    end
    push!(ts.wrapped.results, res)
    res, backtrace()
end

function Test.record(ts::ExtendedTestSet{T}, res::Error) where {T}
    # Ignore errors generated from failed FallbackTestSet
    if occursin(r"^Test.FallbackTestSetException", res.value) ||
           (occursin(r"^TestSetExtensions.ExtendedTestSetException", res.value) &&
            occursin("FallbackTestSetException occurred", res.value))
        throw(ExtendedTestSetException("FallbackTestSetException occurred"))
    end

    println("\n=====================================================")
    Test.record(ts.wrapped, res)
    print("=====================================================\n")
end

function Test.record(ts::ExtendedTestSet{T}, res::Pass) where {T}
    printstyled("."; color = :green)
    Test.record(ts.wrapped, res)
    res
end

Test.record(ts::ExtendedTestSet{T}, res) where {T} = Test.record(ts.wrapped, res)

# When recording DefaultTestSet results to an ExtendedTestSet{FallbackTestSet},
# throw an exception if there are any failures or errors in the DefaultTestSet.
#
# Note: this method is only needed for backward compatibility with Julia<=1.3
function Test.record(ts::ExtendedTestSet{FallbackTestSet}, res::DefaultTestSet)
    # Check for failures and errors
    passes, fails, errors, broken, c_passes, c_fails, c_errors, c_broken =
        Test.get_test_counts(res)
    if (fails > 0) || (errors > 0)
        throw(ExtendedTestSetException("Failure or error occurred in DefaultTestSet nested within FallbackTestSet."))
    end

    return res
end


function Test.finish(ts::ExtendedTestSet{T}) where {T}
    Test.get_testset_depth() == 0 && print("\n\n")
    Test.finish(ts.wrapped)
end

end # module
