import MultipleTestsMultipleFailsTests
import XCTest

var tests = [XCTestCaseEntry]()
tests += MultipleTestsMultipleFailsTests.allTests()
XCTMain(tests)
