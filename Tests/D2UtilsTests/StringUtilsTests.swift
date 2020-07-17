import XCTest
@testable import D2Utils

final class StringUtilsTests: XCTestCase {
    static var allTests = [
        ("testSplitPreservingQuotes", testSplitPreservingQuotes),
        ("testCamelHumps", testCamelHumps)
    ]
    
    func testSplitPreservingQuotes() {
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
        XCTAssertEqual("".levenshteinDistance(to: "ab"), 2)
        XCTAssertEqual("abc".levenshteinDistance(to: ""), 3)
        XCTAssertEqual("kitten".levenshteinDistance(to: "sitting"), 3)
    }

    func testCamelHumps() {
        XCTAssertEqual("".camelHumps, [])
        XCTAssertEqual("test".camelHumps, ["test"])
        XCTAssertEqual("Upper".camelHumps, ["Upper"])
        XCTAssertEqual("camelCase".camelHumps, ["camel", "Case"])
        XCTAssertEqual("UpperCamelCase".camelHumps, ["Upper", "Camel", "Case"])
    }
}
