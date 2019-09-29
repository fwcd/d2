import SwiftDiscord
import D2Permissions

public class WatchCommand: StringCommand {
	public let description = "Fetches a YouTube link from a provided ID"
	public let helpText: String? = "Syntax: ID"
	public let outputValueType = "text"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic

	public init() {}

	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		if let mention = context.message.mentions.first {
			context.guild?.getGuildMember(mention.id) { (member, _) in
				output.append(self.urlWith(id: member?.nick ?? ""))
			}
		} else {
			let id = context.message.mentions.first?.username ?? input
			output.append(urlWith(id: id))
		}
	}

	private func urlWith(id: String) -> String {
		return "https://youtube.com/watch?v=\(id)"
	}
}
