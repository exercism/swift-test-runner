import MultipleTestsSingleFailTests
import XCTest

var tests = [XCTestCaseEntry]()
tests += MultipleTestsSingleFailTests.allTests()
XCTMain(tests)
