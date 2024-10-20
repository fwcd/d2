import Testing
import Utils
@testable import D2Commands

struct ChessPieceUtilsTests {
    @Test func neighborFieldsAsExpected() {
        #expect(Set(neighborFields()) == Set([
            Vec2(x: -1, y: -1),
            Vec2(x: 0, y: -1),
            Vec2(x: 1, y: -1),
            Vec2(x: -1, y: 0),
            Vec2(x: 1, y: 0),
            Vec2(x: -1, y: 1),
            Vec2(x: 0, y: 1),
            Vec2(x: 1, y: 1),
        ]))
    }

    @Test func pieceLetters() {
        expect("Q", matchesPiece: .queen)
        expect("D", matchesPiece: .queen)
        expect("R", matchesPiece: .rook)
        expect("T", matchesPiece: .rook)
        expect("L", matchesPiece: .bishop)
        expect("B", matchesPiece: .bishop)
        expect("N", matchesPiece: .knight)
        expect("S", matchesPiece: .knight)
    }

    private func expect(_ letter: Character, matchesPiece pieceType: ChessPieceType, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(pieceOf(letter: letter)?.pieceType == pieceType, sourceLocation: sourceLocation)
    }
}
