import Logging
import D2MessageIO
import D2Permissions

fileprivate let log = Logger(label: "D2Commands.PollCommand")

// TODO: Use Arg API

public class PollCommand: StringCommand {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Creates a simple poll",
		longDescription: "Creates a message with the given options and 'reaction buttons' that allow users to vote",
		requiredPermissionLevel: .basic
	)

	public init() {}

	public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
		let components = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

		guard components.count >= 1 else {
			output.append(errorText: "Syntax: [poll text] [zero or more vote options...]")
			return
		}

		let options = Array(components.dropFirst())

		guard options.count < 10 else {
			output.append(errorText: "Too many options!")
			return
		}
		guard let client = context.client else {
			output.append(errorText: "Missing client")
			return
		}
		guard let channelId = context.channel?.id else {
			output.append(errorText: "Missing channel id")
			return
		}

		let reactions: [String]
		var embed = Embed(title: "Poll: \(components.first!)")

		log.info("Creating poll `\(embed.title!)` with options \(options)")

		if options.isEmpty {
			reactions = ["👍", "👎", "🤷"]
		} else {
			let range = 0..<options.count
			embed.description = "\(range.map { "\n**\($0):** \(options[$0])" }.joined())"
			reactions = range.compactMap { numberEmojiOf(digit: $0) }
		}

		client.sendMessage(Message(embed: embed), to: channelId).listenOrLogError { sentMessage in
			if let nextMessageId = sentMessage?.id {
                for reaction in reactions {
                    client.createReaction(for: nextMessageId, on: channelId, emoji: reaction)
                }
			}
		}
	}

	private func numberEmojiStringOf(digit: Int) -> String? {
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

	private func numberEmojiOf(digit: Int) -> String? {
		switch digit {
			case 0: return "0⃣"
			case 1: return "1⃣"
			case 2: return "2⃣"
			case 3: return "3⃣"
			case 4: return "4⃣"
			case 5: return "5⃣"
			case 6: return "6⃣"
			case 7: return "7⃣"
			case 8: return "8⃣"
			case 9: return "9⃣"
			default: return nil
		}
	}
}
