import D2Utils

public struct CodenamesBoardModel {
    public let cards: [[Card]]

    public init(width: Int = 5, height: Int = 5) {
        assert(width >= 3 && height >= 3, "Codenames board should be at least 3x3")

        let cardCount = width * height
        let teamAgentCount = (cardCount / 2) - 3
        let innocentCount = (cardCount - (2 * teamAgentCount)) - 1

        let teamAgents = CodenamesRole.allCases.flatMap { Array(repeating: Agent.role($0), count: teamAgentCount) }
        let innocents = Array(repeating: Agent.innocent, count: innocentCount)
        var agents = teamAgents + innocents + [.assasin]

        cards = (0..<height).map { _ in (0..<width).map { _ in
            guard let word = Words.english.randomElement() else { fatalError("English word list is empty") }
            guard let agent = agents.removeRandomElementBySwap() else { fatalError("Too few agents generated, this is a bug") }
            return Card(word: word, agent: agent)
        } }
    }

    public enum Agent {
        case role(CodenamesRole)
        case innocent
        case assasin
    }

    public struct Card {
        public let word: String
        public let agent: Agent
    }
}
