import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(CircularArrayTests.allTests),
		testCase(ComplexTests.allTests),
		testCase(TokenIteratorTests.allTests),
		testCase(StringUtilsTests.allTests),
		testCase(MathUtilsTests.allTests),
		testCase(BinaryHeapTests.allTests)
	]
}
#endif
