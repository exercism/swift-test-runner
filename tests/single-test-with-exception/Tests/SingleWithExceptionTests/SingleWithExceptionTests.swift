import Testing

@testable import SingleWithException

@Test("test Add")
func testAdd() {
  #expect(try sum(2, 3) == 5, "2+3 should equal 5")
}
