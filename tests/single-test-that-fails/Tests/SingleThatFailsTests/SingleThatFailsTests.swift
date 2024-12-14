import Testing

@testable import SingleThatFails

@Test("test Add")
func testAdd() {
  #expect(sum(2, 3) == 5, "2+3 should equal 5")
}
