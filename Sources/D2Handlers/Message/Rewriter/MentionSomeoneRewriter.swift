import D2MessageIO
import Utils

nonisolated(unsafe) private let someonePattern = #/@someone/#

public struct MentionSomeoneRewriter: MessageRewriter {
    public func rewrite(message: Message, sink: any Sink) -> Message? {
        var m = message
        let mentionCount = m.content.matches(of: someonePattern).count
        if mentionCount > 0,
                let guild = m.guild,
                !guild.members.isEmpty {
            let mentions = (0..<mentionCount).map { _ in guild.members.keys.randomElement()! }
            var i = 0
            m.content = m.content.replacing(someonePattern) { _ in
                let mention = mentions[i]
                i += 1
                return "<@\(mention)>"
            }
            m.mentions += mentions.map { guild.members[$0]!.user }
            return m
        }
        return nil
    }
}
