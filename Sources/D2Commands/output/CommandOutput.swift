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
	
	func append(errorText: String, to channel: OutputChannel = .defaultChannel) {
		append(.error(nil, errorText: errorText), to: channel)
	}
	
	func append(_ error: Error, errorText: String = "An error occurred in \(#file)", to channel: OutputChannel = .defaultChannel) {
		append(.error(error, errorText: errorText), to: channel)
	}
	
	func append(_ result: Result<RichValue, Error>, errorText: String = "An error occurred in \(#file)", to channel: OutputChannel = .defaultChannel) {
		switch result {
			case .success(let value):
				append(value, to: channel)
			case .failure(let error):
				append(error, errorText: errorText, to: channel)
		}
	}
}
