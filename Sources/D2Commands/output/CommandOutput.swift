import SwiftDiscord
import D2Utils
import D2Graphics

public protocol CommandOutput {
	var messageLengthLimit: Int? { get }
	
	func append(_ value: RichValue, to channel: OutputChannel)
}

public extension CommandOutput {
	var messageLengthLimit: Int? { return nil }
	
	func append(_ value: RichValue) {
		append(value, to: .defaultChannel)
	}
	
	func append(_ str: String, to channel: OutputChannel = .defaultChannel) {
		append(.text(str), to: channel)
	}
	
	func append(_ embed: DiscordEmbed, to channel: OutputChannel = .defaultChannel) {
		append(.embed(embed), to: channel)
	}
	
	func append(_ image: Image, name: String? = nil, to channel: OutputChannel = .defaultChannel) throws {
		append(.image(image), to: channel)
	}
	
	func append(_ files: [DiscordFileUpload], to channel: OutputChannel = .defaultChannel) {
		append(.files(files), to: channel)
	}
}
