import Testing
@testable import D2Commands

struct ChessNotationParserTests {
    @Test func shortAlgebraicNotation() {
        let parser = ShortAlgebraicNotationParser()

        let bishopMove = parser.parse("Lc4")
        #expect(bishopMove?.pieceType == ChessPieceType.bishop)
        #expect(bishopMove?.destinationX == 2)
        #expect(bishopMove?.destinationY == 4)
        #expect(bishopMove?.isCapture == false)

        let captureMove = parser.parse("Bxb5")
        #expect(captureMove?.pieceType == ChessPieceType.bishop)
        #expect(captureMove?.isCapture == true)
        #expect(captureMove?.destinationX == 1)
        #expect(captureMove?.destinationY == 3)

        let pawnMove = parser.parse("g3")
        #expect(pawnMove?.pieceType == ChessPieceType.pawn)
        #expect(pawnMove?.isCapture == false)
        #expect(pawnMove?.isEnPassant == false)
        #expect(pawnMove?.destinationX == 6)
        #expect(pawnMove?.destinationY == 5)

        let enPassantMove = parser.parse("fxg6 e. p.")
        #expect(enPassantMove?.pieceType == ChessPieceType.pawn)
        #expect(enPassantMove?.isCapture == true)
        #expect(enPassantMove?.isEnPassant == true)
        #expect(enPassantMove?.originX == 5)
        #expect(enPassantMove?.destinationX == 6)
        #expect(enPassantMove?.destinationY == 2)

        let knightMove1 = parser.parse("Sac7")
        #expect(knightMove1?.pieceType == ChessPieceType.knight)
        #expect(knightMove1?.originX == 0)
        #expect(knightMove1?.destinationX == 2)
        #expect(knightMove1?.destinationY == 1)

        let knightMove2 = parser.parse("Ne1xc4")
        #expect(knightMove2?.pieceType == ChessPieceType.knight)
        #expect(knightMove2?.originX == 4)
        #expect(knightMove2?.originY == 7)
        #expect(knightMove2?.isCapture == true)
        #expect(knightMove2?.destinationX == 2)
        #expect(knightMove2?.destinationY == 4)

        let rookMove1 = parser.parse("R1c7")
        #expect(rookMove1?.pieceType == ChessPieceType.rook)
        #expect(rookMove1?.originY == 7)
        #expect(rookMove1?.destinationX == 2)
        #expect(rookMove1?.destinationY == 1)

        let rookMove2 = parser.parse("Th2")
        #expect(rookMove2?.pieceType == ChessPieceType.rook)
        #expect(rookMove2?.destinationX == 7)
        #expect(rookMove2?.destinationY == 6)
    }
}
