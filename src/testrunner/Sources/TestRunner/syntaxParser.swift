import SwiftSyntax
import Foundation
import SwiftParser

class SyntaxParser : SyntaxVisitor {
  var testCases: [TestCases] = []

  override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
    let body = node.body!.statements.description
    let (valid, description) = breakDown(node.attributes)
    if valid {


      testCases.append(TestCases(name: description ?? node.name.description, test_code: body, task_id: nil, functionName: node.name.description))
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

  func breakDown(_ node: LabeledExprListSyntax ) -> String? {
    for child in node {
      if let labeled = child as? LabeledExprSyntax {
        return labeled.expression.description
      }
    }
    return nil
  }
}
