import Foundation
import FoundationXML
import SwiftParser
import SwiftSyntax

struct testFile: Codable {
  var version: Int = 3
  var status: String = "pass"
  var message: String? = nil
  var tests: [TestCases] = []
}

struct TestCases: Codable {
  var name: String = ""
  var test_code: String = ""
  var status: String? = nil
  var message: String? = nil
  var output: String? = nil
  var task_id: Int? = nil
  private var functionName: String? = nil

  init(name: String, test_code: String, task_id: Int? = nil, functionName: String? = nil) {
    self.name = name
    self.test_code = test_code
    self.task_id = task_id
    self.functionName = functionName
  }

  func getFunctionName() -> String {
    return self.functionName ?? ""
  }

  private enum CodingKeys: String, CodingKey {
    case name
    case test_code
    case status
    case message
    case output
    case task_id
  }
}

class TestRunner {

  static func run() {
    let file = CommandLine.arguments[1]

    let url = URL(fileURLWithPath: file)
    let swiftSource = try! String(contentsOf: url)
    let sourceFile = try Parser.parse(source: swiftSource)
    var process = SyntaxParser(viewMode: SyntaxTreeViewMode.all)
    process.walk(sourceFile)
    let testCases = process.testCases

    let xmlFile = CommandLine.arguments[2]
    var xmlSource: String = ""
    do {
      xmlSource = try String(contentsOfFile: xmlFile, encoding: .utf8)
    } catch {
      let errorContext = loadErrorContext()
      print(errorContext)
      writeJson(resultPath: CommandLine.arguments[4], xmlTests: [], error: errorContext)
      return
    }

    let xmlData = Data(xmlSource.utf8)
    let xmlParser = XMLParser(data: xmlData)
    let delegate = MyXMLParserDelegate(tests: testCases)
    xmlParser.delegate = delegate
    xmlParser.parse()
    if !delegate.hasTest {
      let errorContext = loadErrorContext()
      print(errorContext)
      writeJson(resultPath: CommandLine.arguments[4], xmlTests: [], error: errorContext)
      return
    }
    let xmlTests = delegate.tests

    writeJson(resultPath: CommandLine.arguments[4], xmlTests: xmlTests)
  }

  static func loadErrorContext() -> String {
    let file = CommandLine.arguments[3]
    let url = URL(fileURLWithPath: file)
    let swiftSource = try! String(contentsOf: url)
    let linesofText = swiftSource.components(separatedBy: "\n")
    var result = ""
    for index in stride(from: linesofText.count - 1, to: 0, by: -1) {
      guard let safeCharacter = linesofText[index].first else { continue }
      guard safeCharacter != "[" else { break }
      result = linesofText[index] + result
    }
    return result
  }

  static func writeJson(resultPath: String, xmlTests: [TestCases], error: String = "") {
    let encoder = JSONEncoder()
    encoder.outputFormatting.update(with: .prettyPrinted)
    encoder.outputFormatting.update(with: .sortedKeys)
    var json: testFile
    if xmlTests.contains { $0.status == "fail" } {
      json = testFile(status: "fail", tests: xmlTests)
    } else if error != "" {
      json = testFile(status: "error", message: error)
    } else {
      json = testFile(tests: xmlTests)
    }
    var data: Data
    do {
      data = try encoder.encode(json)
    } catch {
      print("Error can't encode json: \(error)")
      return
    }
    let dataJson = String(data: data, encoding: .utf8)!
    do {
      try dataJson.write(toFile: resultPath, atomically: true, encoding: String.Encoding.utf8)
    } catch {
      print("Error resultPath: \(error)")
      return
    }
  }
}

TestRunner.run()
