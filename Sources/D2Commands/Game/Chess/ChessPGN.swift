import Foundation
import Utils

/// Represents a PGN-style game
public struct ChessPGN: CustomStringConvertible, Sendable {
    public var event: String = "?"
    public var site: String = "?"
    public var date: Date? = nil
    public var round: String = "?"
    public var white: String = "?"
    public var black: String = "?"
    public var state: ChessState

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
    public var description: String { (try? formatted()) ?? "<invalid>" }

    public func formatted() throws -> String {
        """
        [Event "\(event)"]
        [Site "\(site)"]
        [Date "\(date.map { dateFormatter.string(from: $0) } ?? "??")"]
        [Round "\(round)"]
        [White "\(white)"]
        [Black "\(black)"]
        [Result "\(formattedResult())"]

        \(formattedMoves())
        """.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func formattedMoves() -> String {
        var moves = state.moveHistory.map(\.algebraicNotation)

        if state.isGameOver {
            moves.append(formattedResult())
        }

        return moves
            .enumerated()
            .map { (i, m) -> String in
                let pre: String = (i % 2 == 0) ? "\((i / 2) + 1). " : ""
                return pre + m
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
