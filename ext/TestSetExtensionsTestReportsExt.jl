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
# using Test: DefaultTestSet, AbstractTestSet
# const DefaultExtendedTestSet = ExtendedTestSet{DefaultTestSet}
# const ReportTestSetOrResult = Union{ReportingResult, Result, AbstractTestSet, ReportingTestSet}
# function TestReports.add_to_ts_default!(ts_default::DefaultExtendedTestSet, x::ReportTestSetOrResult)
#     @debug "add to default"
#     TestReports.add_to_ts_default!(ts_default.wrapped, x)
# end

end
