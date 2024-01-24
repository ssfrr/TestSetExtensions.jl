module TestSetExtensions

using Distributed, Test, DeepDiffs
using Test: AbstractTestSet, DefaultTestSet
using Test: Result, Fail, Error, Pass
export ExtendedTestSet

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

function Test.record(ts::ExtendedTestSet{T}, res::Fail) where {T}
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
                        show(dd)
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

function Test.finish(ts::ExtendedTestSet{T}) where {T}
    Test.get_testset_depth() == 0 && print("\n\n")
    Test.finish(ts.wrapped)
end

end # module
