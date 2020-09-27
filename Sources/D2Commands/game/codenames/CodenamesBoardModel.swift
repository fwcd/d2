import D2Utils

public struct CodenamesBoardModel {
    public private(set) var cards: [[Card]]

    public var width: Int { cards[0].count }
    public var height: Int { cards.count }
    public var remainingWords: [String] { cards.flatMap { $0.filter(\.hidden).map(\.word) } }

    public init(width: Int = 5, height: Int = 5) {
        assert(width >= 3 && height >= 3, "Codenames board should be at least 3x3")

        let cardCount = width * height
        let teamAgentCount = (cardCount / 2) - 3
        let innocentCount = (cardCount - (2 * teamAgentCount)) - 1

        let teamAgents = CodenamesTeam.allCases.flatMap { Array(repeating: Agent.team($0), count: teamAgentCount) }
        let innocents = Array(repeating: Agent.innocent, count: innocentCount)
        var words = Words.nouns.randomlyChosen(count: cardCount)
        var agents = teamAgents + innocents + [.assasin]

        cards = (0..<height).map { y in (0..<width).map { x in
            guard let word = words.removeRandomElementBySwap() else { fatalError("Too few words for the codenames board, currently at y = \(y), x = \(x)") }
            guard let agent = agents.removeRandomElementBySwap() else { fatalError("Too few agents generated, this is a bug") }
            return Card(word: word, agent: agent)
        } }
    }

    public enum Agent: Hashable {
        case team(CodenamesTeam)
        case innocent
        case assasin
    }

    public struct Card {
        public let word: String
        public let agent: Agent
        public var hidden: Bool = true
    }

    public subscript(y: Int, x: Int) -> Card {
        get { cards[y][x] }
        set { cards[y][x] = newValue }
    }

    public func locate(word: String) -> (Int, Int)? {
        (0..<height).flatMap { y in (0..<width).map { x in (y, x) } }.first { (y, x) in self[y, x].word == word }
    }

    public func isAssasinUncovered() -> Bool {
        cards.flatMap { $0 }.contains { $0.agent == .assasin && !$0.hidden }
    }

    public func isWinner(team: CodenamesTeam) -> Bool {
        !isAssasinUncovered() && cards.flatMap { $0 }.filter { $0.agent == .team(team) }.allSatisfy { !$0.hidden }
    }

    @discardableResult
    public mutating func unhide(word: String) -> Card? {
        guard let (y, x) = locate(word: word) else { return nil }
        var card = self[y, x]
        card.hidden = false
        self[y, x] = card
        return card
    }
}
