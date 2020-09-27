public struct CodenamesGame: Game {
    public typealias State = CodenamesState

    public let name: String = "Codenames"
    public let actions: [String: (ActionParameters<State>) throws -> ActionResult<State>] = [
        "move": { ActionResult(nextState: try $0.state.childState(after: try CodenamesGame.parse(move: $0.args, from: $0.state.currentRole))) },
    ]
    public let helpText: String = """
        Codenames is a board game where the players have to guess words
        based on a set of hint-words. Each team has a spymaster that
        dictates a codeword and a count, from which the rest of the team
        has to guess the hint-words on the board.

        For more information on the rules, check out the Wikipedia article:
        <https://en.wikipedia.org/wiki/Codenames_(board_game)>

        When creating a Codenames game with D2, the first
        player in each team is assigned the role of the spymaster,
        i.e. if A invokes

        `codenames @B @C @D @E @F`

        (in that order), A, B, C are going to be the first team
        (with A being a spymaster) and D, E, F the second
        team (with D being a spymaster).
        """

    public init() {}

    private static func parse(move rawMove: String, from role: CodenamesRole) throws -> State.Move {
        switch role {
            case .spymaster(_): return State.Move.codeword(rawMove)
            case .team(_): return State.Move.guess(rawMove.split(separator: " ").map(String.init))
        }
    }
}
