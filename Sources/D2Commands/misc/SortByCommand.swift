import SwiftDiscord
import D2Permissions
import D2Utils

public class SortByCommand: StringCommand {
	public let description = "Fetches the top messages by a certain criterion"
	public let helpText: String? = "Syntax: sortby [criterion]"
	public let outputValueType = "embed"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	private let sortCriteria: [String: (DiscordMessage, DiscordMessage) -> Bool] = [
		"length": comparator { $0.content.count },
		"upvotes": comparator { $0.reactions.first { $0.emoji.name == "upvote" }?.count ?? -1000 }
	]
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		guard let criterion = sortCriteria[input] else {
			output.append("Unrecognized sort criterion: \(input). Try using one of these: \(sortCriteria.keys)")
			return
		}
		guard let channel = context.channel?.id else {
			output.append("No channel found for message")
			return
		}

		context.client?.getMessages(for: channel, selection: nil, limit: 80) { messages, _ in
			let sorted = messages.sorted(by: criterion)
			output.append(DiscordEmbed(
				title: ":star: Top messages",
				fields: Array(sorted
					.map { DiscordEmbed.Field(name: $0.author.username, value: $0.content.nilIfEmpty ?? "No content") }
					.prefix(10))
			))
		}
	}
}
