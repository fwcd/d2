public struct CodenamesGame: Game {
    public typealias State = CodenamesState

    public let name: String = "Codenames"
    public let actions: [String: (ActionParameters<State>) throws -> ActionResult<State>] = [
        "move": { ActionResult(nextState: try $0.state.childState(after: try CodenamesGame.parse(move: $0.args, from: $0.state.currentRole))) },
    ]
    public let helpText: String? = """
        Codenames is a board game where the players have
        to guess words based on a set of hint-words.

        The board contains a grid of hint-words with
        hidden agents beneath. There are four types of agents:
        Blue team agents, red team agents, innocents
        and an assasin.

        The players are split into two teams, then each
        team assign one player the role of the spymaster.
        The teams now take alternating turns in which
        the spymaster has to secretly pick n hint-words
        on the board related to a common term, which he
        presents to the rest of the team together with
        the word count n. The other team members now have
        to guess the hint words. Once the team has placed
        their guess, they uncover the agents beneath.

        Once a team has uncovered all of their agents,
        they have won the game. If a team, however, uncovers
        the assasin (of which there is only a single one),
        they immediately lose.

        For more information, check out the Wikipedia article:
        https://en.wikipedia.org/wiki/Codenames_(board_game)

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
