import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(EchoCommandTests.allTests),
		testCase(TicTacToeCommandTests.allTests),
		testCase(ChessStateTests.allTests),
		testCase(ChessNotationParserTests.allTests)
	]
}
#endif
