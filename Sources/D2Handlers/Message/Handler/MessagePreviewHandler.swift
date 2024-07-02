import Foundation
import Logging
import D2Commands
import D2MessageIO
import Utils

fileprivate let log = Logger(label: "D2Handlers.MessagePreviewHandler")

fileprivate let messageLinkPattern = #/https?://discord(?:app)?.com/channels/(?<guildId>\d+)/(?<channelId>\d+)/(?<messageId>\d+)/#

/// Displays previews of linked messages.
public struct MessagePreviewHandler: MessageHandler {
    @Binding private var configuration: MessagePreviewsConfiguration

    public init(@Binding configuration: MessagePreviewsConfiguration) {
        self._configuration = _configuration
    }

    public func handle(message: Message, sink: any Sink) async -> Bool {
        if sink.name == "Discord",
            let guild = message.guild,
            configuration.enabledGuildIds.contains(guild.id),
            let parsedLink = try? messageLinkPattern.firstMatch(in: message.content),
            let channelId = message.channelId {

            let previewedChannelId = ID(String(parsedLink.channelId), clientName: sink.name)
            let previewedMessageId = ID(String(parsedLink.messageId), clientName: sink.name)

            do {
                let messages = try await sink.getMessages(for: previewedChannelId, limit: 1, selection: .around(previewedMessageId))
                if let message = messages.first,
                    let author = message.author,
                    let member = guild.members[author.id] {
                    do {
                        try await sink.sendMessage(Message(embed: Embed(
                            title: message.content.truncated(to: 200, appending: "..."),
                            author: Embed.Author(
                                name: member.displayName,
                                iconUrl: URL(string: "https://cdn.discordapp.com/avatars/\(author.id)/\(author.avatar).png?size=64")
                            ),
                            image: (message.attachments.first?.url).map(Embed.Image.init(url:))
                        )), to: channelId)
                    } catch {
                        log.warning("Could not send message preview: \(error)")
                    }
                } else {
                    log.warning("Could not generate preview for message with ID \(message.id.map { "\($0)" } ?? "?")")
                }
            } catch {
                log.warning("Could not fetch message for preview: \(error)")
            }
        }

        return false
    }
}
