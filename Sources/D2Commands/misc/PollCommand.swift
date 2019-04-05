import SwiftDiscord
import D2Permissions

public class PollCommand: StringCommand {
	public let description = "Creates a simple poll"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		let components = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
		
		guard components.count >= 1 else {
			output.append("Syntax: [poll text] [zero or more vote options...]")
			return
		}
		
		let options = components.dropFirst()
		
		guard options.count < 10 else {
			output.append("Too many options!")
			return
		}
		guard let client = context.client else {
			output.append("Missing client")
			return
		}
		guard let channelId = context.channel?.id else {
			output.append("Missing channel id")
			return
		}
		
		let reactions: [String]
		var text: String = "Poll: \(components.first!)"
		
		if components.isEmpty {
			reactions = ["thumbsup", "thumbsdown", "shrug"]
		} else {
			let range = 0..<options.count
			text += "\n\(range.map { "\n:\(numberEmojiOf(digit: $0) ?? "?"):: \(options[$0]))" }.joined())"
			reactions = range.compactMap { numberEmojiOf(digit: $0) }
		}
		
		client.sendMessage(DiscordMessage(content: text), to: channelId) { sentMessage, _ in
			guard let messageId = sentMessage?.id else {
				print("Could not add reactions since the sent message has no id")
				return
			}
			
			for reaction in reactions {
				client.createReaction(for: messageId, on: channelId, emoji: reaction)
			}
		}
	}
	
	private func numberEmojiOf(digit: Int) -> String? {
		switch digit {
			case 0: return "zero"
			case 1: return "one"
			case 2: return "two"
			case 3: return "three"
			case 4: return "four"
			case 5: return "five"
			case 6: return "six"
			case 7: return "seven"
			case 8: return "eight"
			case 9: return "nine"
			default: return nil
		}
	}
}
