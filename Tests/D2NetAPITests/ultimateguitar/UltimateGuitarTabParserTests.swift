import XCTest
@testable import D2NetAPIs

final class UltimateGuitarTabParserTests: XCTestCase {
    static var allTests = [
        ("testTabParser", testTabParser)
    ]
    
    func testTabParser() throws {
        let parser = UltimateGuitarTabParser()
        XCTAssertEqual(
            parser.tokenize(tabMarkup: "[Test] this[Thing]\nwith newlines[/closing]"),
            [.tag("Test"), .content(" this"), .tag("Thing"), .content("with newlines"), .closingTag("closing")]
        )
        XCTAssertEqual(
            try parser.parse(tabMarkup: """
                [Test]
                this
                """),
            GuitarTabDocument(
                sections: [
                    .init(title: "Test", nodes: [
                        .text("this")
                    ])
                ]
            )
        )
        XCTAssertEqual(
            try parser.parse(tabMarkup: """
                [Test]
                test some whitespace
                """),
            GuitarTabDocument(
                sections: [
                    .init(title: "Test", nodes: [
                        .text("test some whitespace")
                    ])
                ]
            )
        )
        XCTAssertEqual(
            try parser.parse(tabMarkup: """
                [Test]
                [tab]This is a tab![/tab]
                [tab] This is a tab with padding! [/tab]
                """),
            GuitarTabDocument(
                sections: [
                    .init(title: "Test", nodes: [
                        .tag("tab", [.text("This is a tab!")]),
                        .tag("tab", [.text(" This is a tab with padding! ")])
                    ])
                ]
            )
        )
    }
}
