import D2MessageIO
import D2Utils

/**
 * Writes rich values into MessageIO messages (e.g. for use with Discord).
 */
public struct MessageWriter {
	public init() {}
	
	public func write(value: RichValue) throws -> Message {
		switch value {
			case .none:
				return Message(content: "")
			case let .text(txt):
				if txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					throw MessageWriterError.emptyMessage
				}
				return Message(content: txt)
			case let .mentions(users):
				return Message(content: users.map { "<@\($0.id)>" }.joined(separator: " "))
			case let .image(img):
				return try Message(fromImage: img)
			case let .gif(gif):
				return try Message(fromGif: gif)
			case let .code(code, language: lang):
				return Message(content: """
					```\(lang ?? "")
					\(code)
					```
					""")
			case let .embed(embed):
				return Message(embed: embed)
			case let .error(error, errorText: text):
				return Message(embed: Embed(
					description: ":warning: \(error.map { "\(type(of: $0)): " } ?? "")\(text)",
					footer: Embed.Footer(text: "Check the logs for more details!")
				))
			case let .files(files):
				return Message(files: files)
			case .attachments(_):
				// TODO: Download attachments and re-attach them as fileuploads
				return try write(value: .error(nil, errorText: "Cannot write attachments yet!"))
			case let .compound(components):
				let encoded: [Message] = try components.map { try write(value: $0) }
				return Message(
					content: encoded.compactMap { $0.content.nilIfEmpty }.joined(separator: "\n"),
					embed: encoded.compactMap { $0.embed }.first,
					files: encoded.flatMap { $0.files },
					tts: false
				)
		}
	}
}
