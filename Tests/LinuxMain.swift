import XCTest

import D2CommandTests
import D2GraphicsTests

var tests = [XCTestCaseEntry]()
tests += D2CommandTests.allTests()
tests += D2GraphicsTests.allTests()
XCTMain(tests)
