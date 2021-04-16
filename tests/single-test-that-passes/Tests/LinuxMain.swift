import SingleTestThatPassesTests
import XCTest

var tests = [XCTestCaseEntry]()
tests += SingleTestThatPassesTests.allTests()
XCTMain(tests)
