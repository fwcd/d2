/// A strategy for picking a move.
public protocol GameIntelligence {
    associatedtype State: GameState
        where State: FinitePossibleMoves

    func pickMove(from state: State) -> State.Move
}
