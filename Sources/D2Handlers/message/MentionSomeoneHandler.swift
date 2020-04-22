import D2MessageIO

public struct MentionSomeoneHandler: MessageHandler {
    public func handle(message: Message, from client: MessageClient) -> Bool {
        if message.content.contains("@someone"),
                let guild = message.guild,
                let channelId = message.channelId,
                let randomMemberId = guild.members.keys.randomElement() {
            // Ping the randomly selected person
            client.sendMessage(Message(content: "<@\(randomMemberId)>"), to: channelId)
        }
        return false
    }
}
