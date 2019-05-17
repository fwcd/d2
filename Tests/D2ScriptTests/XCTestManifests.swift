import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(D2ScriptParserTests.allTests)
	]
}
#endif
