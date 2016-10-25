module TestSetExtensions

export DottedTestSet, @includetests

if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
    import Base.Test: record, finish
    using Base.Test: DefaultTestSet, AbstractTestSet, Pass, get_testset_depth
else
    using BaseTestNext
    import BaseTestNext: record, finish
    using BaseTestNext: DefaultTestSet, AbstractTestSet, Pass, get_testset_depth
end

"""
Includes the given test files, given as a list without their ".jl" extensions.
If none are given it will scan the directory of the calling file and include all
the julia files.
"""
macro includetests(tests=[])
    quote
        tests = $tests
        rootfile = @__FILE__
        if length(tests) == 0
            tests = readdir(dirname(rootfile))
            tests = filter(f->endswith(f, ".jl") && f!= basename(rootfile), tests)
        else
            tests = map(f->string(f, ".jl"), tests)
        end
        for test in tests
            print("\n", splitext(test)[1], ": ")
            include(test)
        end
    end
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
