import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
	return [
		testCase(ColorTests.allTests),
		testCase(LzwEncoderTests.allTests)
	]
}
#endif
