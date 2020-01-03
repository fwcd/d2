import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(MinecraftVarIntTests.allTests),
		testCase(WolframAlphaParserDelegateTests.allTests)
	]
}
#endif
