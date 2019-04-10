import SwiftDiscord
import D2Utils
import D2Graphics

public protocol CommandOutput {
	var messageLengthLimit: Int? { get }
	
	func append(_ message: DiscordMessage, to channel: OutputChannel)
}

public extension CommandOutput {
	var messageLengthLimit: Int? { return nil }
	
	func append(_ message: DiscordMessage) {
		append(message, to: .defaultChannel)
	}
	
	func append(_ str: String, to channel: OutputChannel = .defaultChannel) {
		append(DiscordMessage(content: str), to: channel)
	}
	
	func append(_ embed: DiscordEmbed, to channel: OutputChannel = .defaultChannel) {
		append(DiscordMessage(fromEmbed: embed), to: channel)
	}
	
	func append(_ image: Image, to channel: OutputChannel = .defaultChannel) throws {
		append(try DiscordMessage(fromImage: image), to: channel)
	}
	
	func append(_ files: [DiscordFileUpload], to channel: OutputChannel = .defaultChannel) {
		append(DiscordMessage(content: "", files: files))
	}
}
