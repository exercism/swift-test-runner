import XCTest

import MultipleTestsAllPassTests

var tests = [XCTestCaseEntry]()
tests += MultipleTestsAllPassTests.allTests()
XCTMain(tests)
