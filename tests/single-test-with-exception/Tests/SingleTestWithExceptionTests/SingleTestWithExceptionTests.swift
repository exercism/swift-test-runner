import XCTest

@testable import SingleTestWithException

final class SingleTestWithExceptionTests: XCTestCase {
  func testAdd() {
    XCTAssertEqual(try sum(2, 3), 5, "2+3 should equal 5")
  }

  static var allTests = [
    ("testAdd", testAdd)
  ]
}
