public protocol FinitePossibleMoves {
    associatedtype Move: Hashable

    var possibleMoves: Set<Move> { get }
}

public extension GameState where Self: FinitePossibleMoves {
    func isPossible(move: Move, by role: Role) -> Bool { possibleMoves.contains(move) }
}
