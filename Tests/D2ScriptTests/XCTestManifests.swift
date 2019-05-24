import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(D2ScriptASTVisitorTests.allTests),
		testCase(D2ScriptParserTests.allTests),
		testCase(D2ScriptStorageTests.allTests),
		testCase(D2ScriptExecutorTests.allTests)
	]
}
#endif
