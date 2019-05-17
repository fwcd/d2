import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(CircularArrayTests.allTests),
		testCase(ComplexTests.allTests),
		testCase(TokenIteratorTests.allTests)
	]
}
#endif
