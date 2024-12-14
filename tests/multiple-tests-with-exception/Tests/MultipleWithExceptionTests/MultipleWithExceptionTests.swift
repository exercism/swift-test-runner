import Testing

@testable import MultipleWithException

@Test("test Add")
func testAdd() {
  #expect(sum(2, 3) == 5, "2+3 should equal 5")
}

func testSub() {
  #expect(sub(2, 3) == -1)
}

func testMul() {
  #expect(mul(2, 3) == 6)
}

func testThrow() {
  #expect(try throwErr(2, 3) == 5)
}
