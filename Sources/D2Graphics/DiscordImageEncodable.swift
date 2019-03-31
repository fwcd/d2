import SwiftDiscord
import D2Utils

public protocol DiscordImageEncodable: DiscordEncodable {
	var discordImageEncoded: Image? { get }
}

extension DiscordImageEncodable {
	public var discordMessageEncoded: DiscordMessage {
		do {
			if let image = discordImageEncoded {
				return try DiscordMessage(fromImage: image)
			} else {
				return DiscordMessage(content: "Error: No image present")
			}
		} catch {
			return DiscordMessage(content: "Error: Could not encode image")
		}
	}
}
