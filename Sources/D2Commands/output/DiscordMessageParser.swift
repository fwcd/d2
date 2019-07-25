import SwiftDiscord
import D2Utils

// The first group matches the language, the second group matches the code
fileprivate let codePattern = try! Regex(from: "(?:`(?:``(?:(\\w*)\n)?)?)?([^`]+)`*")

/**
 * Parses Discord messages into rich values.
 */
public struct DiscordMessageParser {
	public func parse(message: DiscordMessage) -> RichValue {
		var values: [RichValue] = []
		
		// Parse message content
		if let codeGroups = codePattern.firstGroups(in: message.content) {
			let language = codeGroups[1].nilIfEmpty
			let code = codeGroups[2]
			values.append(.code(code, language: language))
		} else {
			values.append(.text(message.content))
		}
		
		// TODO: Handle images
		
		// Convert values to RichValue
		switch values.count {
			case 0: return .none
			case 1: return values.first!
			default: return .compound(values)
		}
	}
}
