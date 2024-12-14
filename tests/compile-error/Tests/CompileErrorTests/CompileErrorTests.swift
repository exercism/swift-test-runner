import Testing

@testable import CompileError

@Test("test Add")
func testAdd() {
   #expect(sum(2, 3) == 5)
}

