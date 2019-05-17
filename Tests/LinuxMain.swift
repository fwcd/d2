import XCTest

import D2UtilsTests
import D2CommandTests
import D2GraphicsTests
import D2WebAPITests
import D2ScriptTests

var tests = [XCTestCaseEntry]()
tests += D2CommandTests.allTests()
tests += D2UtilsTests.allTests()
tests += D2GraphicsTests.allTests()
tests += D2WebAPITests.allTests()
tests += D2ScriptTests.allTests()
XCTMain(tests)
