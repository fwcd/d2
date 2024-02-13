import XCTest
@testable import D2Commands

final class ChessNotationParserTests: XCTestCase {
    func testShortAlgebraicNotation() throws {
        let parser = ShortAlgebraicNotationParser()

        let bishopMove = parser.parse("Lc4")
        XCTAssertEqual(bishopMove?.pieceType, ChessPieceType.bishop)
        XCTAssertEqual(bishopMove?.destinationX, 2)
        XCTAssertEqual(bishopMove?.destinationY, 4)
        XCTAssertEqual(bishopMove?.isCapture, false)

        let captureMove = parser.parse("Bxb5")
        XCTAssertEqual(captureMove?.pieceType, ChessPieceType.bishop)
        XCTAssertEqual(captureMove?.isCapture, true)
        XCTAssertEqual(captureMove?.destinationX, 1)
        XCTAssertEqual(captureMove?.destinationY, 3)

        let pawnMove = parser.parse("g3")
        XCTAssertEqual(pawnMove?.pieceType, ChessPieceType.pawn)
        XCTAssertEqual(pawnMove?.isCapture, false)
        XCTAssertEqual(pawnMove?.isEnPassant, false)
        XCTAssertEqual(pawnMove?.destinationX, 6)
        XCTAssertEqual(pawnMove?.destinationY, 5)

        let enPassantMove = parser.parse("fxg6 e. p.")
        XCTAssertEqual(enPassantMove?.pieceType, ChessPieceType.pawn)
        XCTAssertEqual(enPassantMove?.isCapture, true)
        XCTAssertEqual(enPassantMove?.isEnPassant, true)
        XCTAssertEqual(enPassantMove?.originX, 5)
        XCTAssertEqual(enPassantMove?.destinationX, 6)
        XCTAssertEqual(enPassantMove?.destinationY, 2)

        let knightMove1 = parser.parse("Sac7")
        XCTAssertEqual(knightMove1?.pieceType, ChessPieceType.knight)
        XCTAssertEqual(knightMove1?.originX, 0)
        XCTAssertEqual(knightMove1?.destinationX, 2)
        XCTAssertEqual(knightMove1?.destinationY, 1)

        let knightMove2 = parser.parse("Ne1xc4")
        XCTAssertEqual(knightMove2?.pieceType, ChessPieceType.knight)
        XCTAssertEqual(knightMove2?.originX, 4)
        XCTAssertEqual(knightMove2?.originY, 7)
        XCTAssertEqual(knightMove2?.isCapture, true)
        XCTAssertEqual(knightMove2?.destinationX, 2)
        XCTAssertEqual(knightMove2?.destinationY, 4)

        let rookMove1 = parser.parse("R1c7")
        XCTAssertEqual(rookMove1?.pieceType, ChessPieceType.rook)
        XCTAssertEqual(rookMove1?.originY, 7)
        XCTAssertEqual(rookMove1?.destinationX, 2)
        XCTAssertEqual(rookMove1?.destinationY, 1)

        let rookMove2 = parser.parse("Th2")
        XCTAssertEqual(rookMove2?.pieceType, ChessPieceType.rook)
        XCTAssertEqual(rookMove2?.destinationX, 7)
        XCTAssertEqual(rookMove2?.destinationY, 6)
    }
}
