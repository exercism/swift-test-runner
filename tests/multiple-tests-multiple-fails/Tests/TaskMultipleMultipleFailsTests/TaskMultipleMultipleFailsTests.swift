import Testing

@testable import MultipleMultipleFails

@Suite struct TaskMultipleMultipleFailsTests {
  @Test("test Add")
  func testAdd() {
    #expect(sum(2, 3) == 5, "2+3 should equal 5")
  }

  @Test("test Sub")
  func testSub() {
    #expect(sub(2, 3) == -1)
  }

  @Test("test Mul")
  func testMul() {
    #expect(mul(2, 3) == 6)
  }
}
