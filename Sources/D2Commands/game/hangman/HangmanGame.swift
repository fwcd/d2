public struct HangmanGame: Game {
    public typealias State = HangmanState

    public let name: String = "hangman"
    public let renderFirstBoard: Bool = true
    public let isRealTime: Bool = true
    public let actions: [String: (ActionParameters<State>) throws -> ActionResult<State>] = [
        "try": {
            let next = try $0.state.childState(after: HangmanMove(fromString: $0.args))
            return ActionResult(nextState: next)
        }
    ]
    public let helpText: String = """
        The Hangman game. Every player can make
        guesses using `try`, e.g. like this:

        `try s`
        `try a`
        `try house`
        """
    
    public init() {}
}
