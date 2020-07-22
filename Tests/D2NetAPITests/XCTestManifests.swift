import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(MinecraftIntegerTests.allTests),
		testCase(MinecraftVarIntTests.allTests),
		testCase(WolframAlphaParserDelegateTests.allTests),
		testCase(UltimateGuitarTabParserTests.allTests)
	]
}
#endif
