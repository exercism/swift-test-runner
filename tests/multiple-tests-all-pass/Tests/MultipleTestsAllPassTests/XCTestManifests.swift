import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(MultipleTestsAllPassTests.allTests),
        testCase(SecondSuite.allTests),
    ]
}
#endif
