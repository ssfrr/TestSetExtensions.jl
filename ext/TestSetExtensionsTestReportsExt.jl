module TestSetExtensionsTestReportsExt

using TestSetExtensions: ExtendedTestSet
using TestReports

TestReports.testset_properties(ts::ExtendedTestSet) = ts.testset_properties
function TestReports.record_testset_property!(ts::ExtendedTestSet, name::AbstractString, value)
    push!(ts.testset_properties, name => value)
    @debug "" ts.testset_properties
    return ts
end
TestReports.test_properties(ts::ExtendedTestSet) = ts.test_properties
function TestReports.record_test_property!(ts::ExtendedTestSet, name::AbstractString, value)
    push!(ts.test_properties, name => value)
    @debug "" ts.test_properties
    return ts
end

end
