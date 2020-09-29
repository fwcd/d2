import Foundation
import Logging
import D2Commands
import D2MessageIO
import Utils

fileprivate let log = Logger(label: "D2Handlers.MessagePreviewHandler")

/// The link pattern capturing in order:
///
/// - The guild id
/// - The channel id
/// - The message id
fileprivate let messageLinkPattern = try! Regex(from: "https?://discord(?:app)?.com/channels/(\\d+)/(\\d+)/(\\d+)")

/// Displays previews of linked messages.
public struct MessagePreviewHandler: MessageHandler {
    @AutoSerializing private var configuration: MessagePreviewsConfiguration

    public init(configuration: AutoSerializing<MessagePreviewsConfiguration>) {
        self._configuration = configuration
    }

    public func handle(message: Message, from client: MessageClient) -> Bool {
        if client.name == "Discord",
            let guildId = message.guild?.id,
            configuration.enabledGuildIds.contains(guildId),
            let parsedLink = messageLinkPattern.firstGroups(in: message.content),
            let channelId = message.channelId {

            let previewedChannelId = ID(parsedLink[2], clientName: client.name)
            let previewedMessageId = ID(parsedLink[3], clientName: client.name)

            client.getMessages(for: previewedChannelId, limit: 1, selection: .around(previewedMessageId)).listenOrLogError { messages in
                if let message = messages.first {
                    client.sendMessage(Message(embed: Embed(
                        title: message.content.truncate(200, appending: "..."),
                        author: message.author.map { Embed.Author(
                            name: $0.username,
                            iconUrl: URL(string: "https://cdn.discordapp.com/avatars/\($0.id)/\($0.avatar).png?size=64")
                        ) },
                        image: (message.attachments.first?.url).map(Embed.Image.init(url:))
                    )), to: channelId)
                } else {
                    log.warning("Could not generate preview for message with ID \(message.id.map { "\($0)" } ?? "?")")
                }
            }
        }

        return false
    }
}
