import SwiftDiscord
import D2Utils

public protocol DiscordImageEncodable: DiscordEncodable {
	var discordImageEncoded: Image? { get }
}

extension DiscordImageEncodable {
	public var discordEncoded: DiscordEncoded {
		do {
			if let image = discordImageEncoded {
				return try DiscordEncoded(fromImage: image)
			} else {
				return DiscordEncoded(content: "Error: No image present")
			}
		} catch {
			return DiscordEncoded(content: "Error: Could not encode image")
		}
	}
}
