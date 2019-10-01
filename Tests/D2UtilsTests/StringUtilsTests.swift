import XCTest
@testable import D2Utils

final class StringUtilsTests: XCTestCase {
    static var allTests = [
        ("testSplitPreservingQuotes", testSplitPreservingQuotes)
    ]
    
    func testSplitPreservingQuotes() throws {
        XCTAssertEqual("this is | a string | separated by pipes".splitPreservingQuotes(by: "|"), [
            "this is ",
            " a string ",
            " separated by pipes"
        ])
        XCTAssertEqual("this string has \"quoted | regions\" | that ' should | ` | not ` | be ' | split".splitPreservingQuotes(by: "|"), [
            "this string has \"quoted | regions\" ",
            " that ' should | ` | not ` | be ' ",
            " split"
        ])
    }
}
