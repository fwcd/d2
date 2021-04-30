import Foundation
import Utils

fileprivate func makeDateFormatter(_ format: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter
}

/// Represents a PGN-style game
public struct ChessPGN: CustomStringConvertible {
    public var event: String = "?"
    public var site: String = "?"
    public var date: Date? = nil
    public var round: String = "?"
    public var white: String = "?"
    public var black: String = "?"
    public var state: ChessState

    public var description: String { (try? formatted()) ?? "<invalid>" }

    public func formatted() throws -> String {
        """
        [Event "\(event)"]
        [Site "\(site)"]
        [Date "\(date.map { makeDateFormatter("yyyy.MM.dd").string(from: $0) } ?? "??")"]
        [Round "\(round)"]
        [White "\(white)"]
        [Black "\(black)"]
        [Result "\(formattedResult())"]

        \(formattedMoves()) \(state.isGameOver ? formattedResult() : "")
        """.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func formattedMoves() -> String {
        state.moveHistory
            .enumerated()
            .map { (i, m) -> String in
                let pre: String = (i % 2 == 0) ? "\(i + 1). " : " "
                return pre + m.algebraicNotation
            }
            .joined(separator: " ")
    }

    private func formattedResult() -> String {
        if state.isGameOver {
            let winner = state.winner
            return "\(winner == .white ? 1 : 0)-\(winner == .black ? 1 : 0)"
        } else {
            return "*"
        }
    }
}
