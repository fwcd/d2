import D2Utils
import D2MessageIO

public struct FollowUpConversator: Conversator {
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func answer(input: String, on guildId: GuildID) throws -> String? {
        guard let last = input
            .split(separator: " ")
            .last
            .map({ String($0) })?.nilIfEmpty else { return nil }
        let followUps = try messageDB.followUps(to: last, on: guildId)

        if !followUps.isEmpty {
            let candidates = followUps.map { ($0.1, matchingSuffixLength($0.0, input)) }
            guard let distribution = CustomDiscreteDistribution(normalizing: candidates) else { return nil }
            let sample = distribution.sample()
            if !sample.isEmpty {
                return sample
            }
        }

        return nil
    }

    private func matchingSuffixLength(_ lhs: String, _ rhs: String) -> Int {
        var i = 0
        var iterator = zip(lhs.reversed(), rhs.reversed()).makeIterator()
        while let (l, r) = iterator.next(), l == r {
            i += 1
        }
        return i
    }
}
