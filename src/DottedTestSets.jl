module DottedTestSets

export DottedTestSet

if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
    import Base.Test: record, finish
    using Base.Test: DefaultTestSet, AbstractTestSet, Pass, get_testset_depth
else
    using BaseTestNext
    import BaseTestNext: record, finish
    using BaseTestNext: DefaultTestSet, AbstractTestSet, Pass, get_testset_depth
end


type DottedTestSet{T<:AbstractTestSet} <: AbstractTestSet
    wrapped::T

    DottedTestSet(desc) = new(T(desc))
end

function DottedTestSet(desc; wrap=DefaultTestSet)
    DottedTestSet{wrap}(desc)
end

function record(ts::DottedTestSet, res::Pass)
    print_with_color(:green, ".")
    record(ts.wrapped, res)
    res
end

record(ts::DottedTestSet, res) = record(ts.wrapped, res)

function finish(ts::DottedTestSet)
    get_testset_depth() == 0 && print("\n\n")
    finish(ts.wrapped)
end

end # module
