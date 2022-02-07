public struct WordleGame: Game {
    public typealias State = WordleState

    public let name: String = "wordle"
    public let renderFirstBoard: Bool = false
    public let isRealTime: Bool = true
    public let actions: [String: (ActionParameters<State>) throws -> ActionResult<State>] = [
        "try": {
            // TODO: Figure out how to disambiguate between multiple
            //       roles of the player if he plays against himself.
            guard let role = $0.state.rolesOf(player: $0.player).first else { throw WordleError.playerHasNoRole }
            let next = try $0.state.childState(after: WordleMove(fromString: $0.args), by: role, options: .commit)
            return ActionResult(nextState: next)
        }
    ]
    public let helpText: String = """
        The Wordle game. Players can make guesses
        using `try`, e.g. like this:

        `try crane`
        `try words`
        """

    public init() {}
}
