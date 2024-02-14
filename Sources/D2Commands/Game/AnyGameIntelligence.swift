/// Type-erased wrapper around a GameIntelligence.
public struct AnyGameIntelligence<State>: GameIntelligence where State: GameState {
    private let _pickMove: (State) throws -> State.Move

    public init<I>(_ intelligence: I) where I: GameIntelligence, I.State == State {
        _pickMove = intelligence.pickMove(from:)
    }

    public func pickMove(from state: State) throws -> State.Move {
        try _pickMove(state)
    }
}
