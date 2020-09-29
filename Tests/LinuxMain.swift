import XCTest

import UtilsTests
import D2CommandTests
import GraphicsTests
import D2NetAPITests
import D2ScriptTests

var tests = [XCTestCaseEntry]()
tests += D2CommandTests.allTests()
tests += UtilsTests.allTests()
tests += GraphicsTests.allTests()
tests += D2NetAPITests.allTests()
tests += D2ScriptTests.allTests()
XCTMain(tests)
