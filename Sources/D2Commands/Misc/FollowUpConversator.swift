import Dispatch
import Utils
import D2MessageIO

public struct FollowUpConversator: Conversator, Sendable {
    private let messageDB: MessageDatabase

    public init(messageDB: MessageDatabase) {
        self.messageDB = messageDB
    }

    public func answer(input: String, on guildId: GuildID) async throws -> String? {
        try await withCheckedThrowingContinuation { continuation in
            // Per https://stackoverflow.com/a/69573708 we use GCD to asyncify our slow synchronous work
            DispatchQueue.global().async {
                guard let last = input
                    .split(separator: " ")
                    .last
                    .map({ String($0) })?.nilIfEmpty else {
                    continuation.resume(returning: nil)
                    return
                }

                do {
                    let followUps = try messageDB.followUps(to: last, on: guildId)

                    if !followUps.isEmpty {
                        let candidates = followUps.map { ($0.1, matchingSuffixLength($0.0, input)) }
                        guard let distribution = CustomDiscreteDistribution(normalizing: candidates) else {
                            continuation.resume(returning: nil)
                            return
                        }
                        let sample = distribution.sample()
                        if !sample.isEmpty {
                            continuation.resume(returning: sample)
                            return
                        }
                    }

                    continuation.resume(returning: nil)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
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
