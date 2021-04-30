/// A strategy for picking a move.
public protocol GameIntelligence {
    associatedtype State: GameState

    func pickMove(from state: State) throws -> State.Move
}
