import XCTest
@testable import D2NetAPIs

final class UltimateGuitarTabParserTests: XCTestCase {
    func testTabParser() throws {
        let parser = UltimateGuitarTabParser()
        XCTAssertEqual(
            parser.tokenize(tabMarkup: "[Test] this[Thing]\nwith newlines[/closing]"),
            [.tag("Test"), .content(" this"), .tag("Thing"), .newlines, .content("with newlines"), .closingTag("closing")]
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
                        .tag("tab", [.text("This is a tab!")]), .text("\n"),
                        .tag("tab", [.text(" This is a tab with padding! ")])
                    ])
                ]
            )
        )
        XCTAssertEqual(
            try parser.parse(tabMarkup: """
                [1. Verse]
                [tab]    [ch]Am[/ch]    [ch]C[/ch]    [ch]G[/ch]    [ch]D[/ch]
                I just need to get it off my chest, this is a unit test![/tab]

                [Chorus]
                [tab]Roses are red, violets are blue,[/tab]
                [tab]i hope this succeeds, and you maybe too![/tab]
                """),
            GuitarTabDocument(
                sections: [
                    .init(title: "1. Verse", nodes: [
                        .tag("tab", [
                            .text("    "), .tag("ch", [.text("Am")]), .text("    "), .tag("ch", [.text("C")]), .text("    "), .tag("ch", [.text("G")]), .text("    "), .tag("ch", [.text("D")]),
                            .text("\nI just need to get it off my chest, this is a unit test!")
                        ])
                    ]),
                    .init(title: "Chorus", nodes: [
                        .tag("tab", [.text("Roses are red, violets are blue,")]), .text("\n"),
                        .tag("tab", [.text("i hope this succeeds, and you maybe too!")])
                    ])
                ]
            )
        )
    }
}
