import D2MessageIO
import Utils

struct WhisperPostprocessor: MessagePostprocessor {
    func postprocess(message: Message, context: CommandContext) async throws -> Message {
        var message = message

        if let channelId = context.channel?.id,
           let config = context.whisperConfiguration,
           config.wrappedValue.enabledChannelIds.contains(channelId) {
            message.content = whisperify(string: message.content)
            message.embeds = message.embeds.map(whisperify(embed:))
        }

        return message
    }

    private func whisperify(embed: Embed) -> Embed {
        var embed = embed

        embed.description = embed.description.map(whisperify(string:))
        embed.fields = embed.fields.map(whisperify(field:))

        return embed
    }

    private func whisperify(field: Embed.Field) -> Embed.Field {
        var field = field

        field.value = whisperify(string: field.value)

        return field
    }

    private func whisperify(string: String) -> String {
        string
            .replacing(#/```\S*/#, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacing(#/(?<prefix>^|\n)(?<suffix>\S)/#) { "\($0.prefix)-# \($0.suffix)" }
    }
}
