public struct HangmanGame: Game {
    public typealias State = HangmanState

    public let name: String = "hangman"
    public let renderFirstBoard: Bool = true
    public let isRealTime: Bool = true
    public let actions: [String: (ActionParameters<State>) throws -> ActionResult<State>] = [
        "try": {
            // TODO: Figure out how to disambiguate between multiple
            //       roles of the player if he plays against himself.
            guard let role = $0.state.rolesOf(player: $0.player).first else { throw HangmanError.playerHasNoRole }
            do {
                let next = try $0.state.childState(after: HangmanMove(fromString: $0.args), by: role)
                return ActionResult(nextState: next)
            } catch GameError.invalidMove(let e) {
                guard $0.state.hasTriesLeft(role: role) else { throw HangmanError.noTriesLeft }

                var next = $0.state
                try next.penalize(role: role)
                let remaining = next.remainingTries[role]!

                return ActionResult(nextState: next, text: "`\($0.player.username)` now has \(remaining) \(remaining == 1 ? "try" : "tries") left!")
            }
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
