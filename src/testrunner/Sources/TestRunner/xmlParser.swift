import Foundation
import FoundationXML

class MyXMLParserDelegate: NSObject, XMLParserDelegate {
  var counter = 0
  var tests: [TestCases]  // Add a property for tests
  var hasTest = false

  init(tests: [TestCases]) {
    self.tests = tests
  }
  // Called when the parser encounters the start of an element
  func parser(
    _ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
    qualifiedName _: String?, attributes attributeDict: [String: String] = [:]
  ) {
    if elementName == "failure" {
      tests[counter].status = "fail"
      tests[counter].message = attributeDict["message"]
    } else if elementName == "testcase" {
      hasTest = true
      counter =
        tests.firstIndex(where: {
          $0.getFunctionName() == attributeDict["name"]?.filter { !"()".contains($0) }
        }) ?? counter
      tests[counter].status = "pass"
    }
  }
}
