import XCTest

#if !canImport(ObjectiveC)
  public func allTests() -> [XCTestCaseEntry] {
    return [
      testCase(MultipleTestsSingleFailTests.allTests),
      testCase(SecondSuite.allTests),
    ]
  }
#endif
