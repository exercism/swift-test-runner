import Testing

@testable import SingleWithException

@Test("test No Exception")
func testNoException() {
  #expect(try div(5, 1) == 5, "2+3 should equal 5")
}

@Test("test Add")
func testAdd() {
  #expect(try div(5, 0) == 5, "2+3 should equal 5")
}
