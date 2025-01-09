import Testing

@testable import MultipleSingleFail

@Suite struct TaskMultipleSingleFailTests {
  @Test("test Add")
  func testAdd() {
    #expect(sum(2, 3) == 5, "2+3 should equal 5")
  }

  @Test("test Sub")
  func testSub()  {
    #expect(sub(2, 3) == -1)
  }

  @Test("test Mul")
  func testMul() {
    #expect(mul(2, 3) == 6)
  }


  @Test("test Add 2")
  func testAdd_2() {
    #expect(sum(12, 13) == 25, "12+13 should equal 25")
  }

  @Test("test Sub 2")
  func testSub_2() {
    #expect(sub(12, 13) == -1)
  }

  @Test("test Mul 2")
  func testMul_2() {
    #expect(mul(12, 13) == 156)
  }
}
