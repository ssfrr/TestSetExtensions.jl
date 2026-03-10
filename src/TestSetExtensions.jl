module TestSetExtensions

using Distributed, Test, DeepDiffs
using Test: AbstractTestSet, DefaultTestSet
using Test: Result, Fail, Error, Pass
export ExtendedTestSet

struct ExtendedTestSet{T<:AbstractTestSet} <: AbstractTestSet
    wrapped::T
    # for compatibility with TestReports
    testset_properties::Vector{Pair{String, Any}}
    test_properties::Vector{Pair{String, Any}}
    ExtendedTestSet{T}(desc) where {T} = new(T(desc), Pair{String, Any}[], Pair{String, Any}[])
end

function Base.getproperty(t::T, s::Symbol) where {T <: ExtendedTestSet}
    @debug "get $s"
    if s ∈ fieldnames(T)
        return getfield(t, s)
    else
        return getproperty(t.wrapped, s)
    end
end

function Base.setproperty!(t::T, s::Symbol, v) where {T <: ExtendedTestSet}
    @debug "set $s"
    # ExtendedTestSet is immutable and has no properties you can set
    # so we can assume delegation
    return setproperty!(t.wrapped, s, v)
end

struct FailDiff <: Result
    result::Fail
end

function ExtendedTestSet(desc; wrap=DefaultTestSet)
    ExtendedTestSet{wrap}(desc)
end

function isVector(e)
    if e.head === :vect
        return true
    end
    #Float32 or Int32 arrays get here as Ref's to Vector
    if e.head === :ref && isa(e.args, Vector)
        return true
    end
    return false
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
                    elseif isVector(test_expr.args[2]) && isVector(test_expr.args[3])
                        deepdiff(test_expr.args[2].args, test_expr.args[3].args)
                    elseif test_expr.args[2].head === :call && test_expr.args[3].head === :call &&
                            test_expr.args[2].args[1].head === :curly && test_expr.args[3].args[1].head === :curly
                        deepdiff(Base.eval(test_expr.args[2].args), Base.eval(test_expr.args[3].args))
                    elseif test_expr.args[2].head === :vcat && test_expr.args[3].head === :vcat
                        # matrices
                        deepdiff(test_expr.args[2].args, test_expr.args[3].args)
                    end

                    # note there is an implicit `else nothing` branch to the if-block above
                    if !isa(dd, DeepDiffs.SimpleDiff) && dd !== nothing
                        # SimpleDiff has no pretty printing
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

        Base.show_backtrace(stdout, Test.scrub_backtrace(backtrace(), ts.wrapped.file, Test.extract_file(res.source)))
        # show_backtrace doesn't print a trailing newline
        println()
        println("=====================================================")
    end
    push!(ts.wrapped.results, res)
    res, backtrace()
end

function Test.record(ts::ExtendedTestSet{T}, res::Error) where {T}
    println()
    println("=====================================================")
    Test.record(ts.wrapped, res)
    println("=====================================================")
    return res
end

function Test.record(ts::ExtendedTestSet{T}, res::Pass) where {T}
    printstyled("."; color = :green)
    Test.record(ts.wrapped, res)
    return res
end

function Test.record(ts::ExtendedTestSet{T}, res) where {T}
    Test.record(ts.wrapped, res)
    return res
end

function Test.finish(ts::ExtendedTestSet{T}) where {T}
    Test.get_testset_depth() == 0 && print("\n\n")
    if Test.get_testset_depth() != 0
        # Attach this test set to the parent test set
        parent_ts = Test.get_testset()
        Test.record(parent_ts, ts)
        return ts
    end

    Test.finish(ts.wrapped)
    return ts
end

end # module
