import XCTest

import D2UtilsTests
import D2CommandTests
import D2GraphicsTests
import D2WebAPITests

var tests = [XCTestCaseEntry]()
tests += D2CommandTests.allTests()
tests += D2UtilsTests.allTests()
tests += D2GraphicsTests.allTests()
tests += D2WebAPITests.allTests()
XCTMain(tests)
