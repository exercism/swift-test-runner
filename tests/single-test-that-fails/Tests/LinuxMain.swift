import SingleTestThatFailsTests
import XCTest

var tests = [XCTestCaseEntry]()
tests += SingleTestThatFailsTests.allTests()
XCTMain(tests)
