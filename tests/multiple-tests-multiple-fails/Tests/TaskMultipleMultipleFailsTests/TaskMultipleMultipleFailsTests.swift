import Testing
import Foundation

@testable import MultipleMultipleFails

let RUNALL = Bool(ProcessInfo.processInfo.environment["RUNALL", default: "false"]) ?? false

@Suite struct TaskMultipleMultipleFailsTests {
  @Test("test Add")
  func testAdd() {
    #expect(sum(2, 3) == 5, "2+3 should equal 5")
  }

  @Test("test Sub", .enabled(if: RUNALL))
  func testSub() {
    #expect(sub(2, 3) == -1)
  }

  @Test("test Mul", .enabled(if: RUNALL))
  func testMul() {
    #expect(mul(2, 3) == 6)
  }
}
