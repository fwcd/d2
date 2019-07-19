import SwiftDiscord
import D2Utils

/**
 * Writes rich values into Discord messages.
 */
public struct DiscordMessageWriter { // TODO: Update to MessageIO
	public init() {}
	
	public func write<MessageLike>(value: RichValue) throws -> MessageLike where MessageLike: DiscordMessageLikeInitializable {
		switch value {
			case .none:
				return MessageLike(fromContent: "")
			case let .text(txt):
				if txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					throw DiscordMessageWriterError.emptyMessage
				}
				return MessageLike(fromContent: txt)
			case let .image(img):
				return try MessageLike(fromImage: img)
			case let .gif(gif):
				return MessageLike(fromGif: gif)
			case let .code(code, language: lang):
				return MessageLike(fromContent: """
					```\(lang ?? "")
					\(code)
					```
					""")
			case let .embed(embed):
				return MessageLike(fromEmbed: embed)
			case let .files(files):
				return MessageLike(fromFiles: files)
			case let .compound(components):
				let encoded: [DiscordEncoded] = try components.map { try write(value: $0) }
				return MessageLike(
					content: encoded.compactMap { $0.content.nilIfEmpty }.joined(separator: "\n"),
					embed: encoded.compactMap { $0.embed }.first,
					files: encoded.flatMap { $0.files },
					tts: false
				)
		}
	}
}
