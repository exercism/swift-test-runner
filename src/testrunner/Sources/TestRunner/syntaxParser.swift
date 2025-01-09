import Foundation
import SwiftParser
import SwiftSyntax

class SyntaxParser: SyntaxVisitor {
  var testCases: [TestCases] = []

  override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
    let body = node.body!.statements.description
    let (valid, description) = breakDown(node.attributes)
    if valid {
      let intendentRemovedBody = removeIndentation(body)
      let removedFirstNewLineBody = intendentRemovedBody.dropFirst()

      testCases.append(
        TestCases(
          name: description ?? node.name.description, test_code: String(removedFirstNewLineBody),
          task_id: nil, functionName: node.name.description))
    }
    return .visitChildren
  }

  func breakDown(_ node: AttributeListSyntax) -> (Bool, String?) {

    var valid = false
    var description: String? = nil

    for child in node {
      if let attribute = child.as(AttributeSyntax.self) {
        valid = String(describing: attribute.attributeName) == "Test"
        if let argument = attribute.arguments {
          description = breakDown(argument.cast(LabeledExprListSyntax.self))
        }
      }
    }
    return (valid, description)
  }

  func breakDown(_ node: LabeledExprListSyntax) -> String? {
    for child in node {
      if let labeled = child as? LabeledExprSyntax {
        return labeled.expression.description.trimmingCharacters(
          in: CharacterSet(charactersIn: "\""))
      }
    }
    return nil
  }

  private func removeIndentation(_ string: String) -> String {
    let lines = string.components(separatedBy: "\n")
    let indentation = lines.dropFirst().first?.prefix(while: { $0 == " " })
    return lines.map { $0.dropFirst(indentation?.count ?? 0) }.joined(separator: "\n")
  }
}
