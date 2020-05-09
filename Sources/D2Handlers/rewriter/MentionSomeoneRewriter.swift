import D2MessageIO
import D2Utils

fileprivate let someonePattern = try! Regex(from: "@someone")

public struct MentionSomeoneRewriter: MessageRewriter {
    public func rewrite(message: Message, from client: MessageClient) -> Message {
        var m = message
        if someonePattern.matchCount(in: m.content) > 0,
                let guild = m.guild,
                !guild.members.isEmpty {
            m.content = someonePattern.replace(in: m.content) { _ in
                "<@\(guild.members.keys.randomElement()!)>"
            }
        }
        return m
    }
}
