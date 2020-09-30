import XCTest

import D2CommandTests
import D2NetAPITests
import D2ScriptTests

var tests = [XCTestCaseEntry]()
tests += D2CommandTests.allTests()
tests += D2NetAPITests.allTests()
tests += D2ScriptTests.allTests()
XCTMain(tests)
