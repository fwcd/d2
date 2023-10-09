import D2MessageIO
import Utils

fileprivate let someonePattern = try! Regex(from: "@someone")

public struct MentionSomeoneRewriter: MessageRewriter {
    public func rewrite(message: Message, from client: any Sink) -> Message? {
        var m = message
        let mentionCount = someonePattern.matchCount(in: m.content)
        if mentionCount > 0,
                let guild = m.guild,
                !guild.members.isEmpty {
            let mentions = (0..<mentionCount).map { _ in guild.members.keys.randomElement()! }
            var i = 0
            m.content = someonePattern.replace(in: m.content) { _ in
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
