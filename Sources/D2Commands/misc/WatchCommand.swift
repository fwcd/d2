import SwiftDiscord
import D2Permissions

public class WatchCommand: StringCommand {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Outputs the YouTube link given a video ID",
		longDescription: "Constructs the YouTube video link from an ID",
		requiredPermissionLevel: .basic
	)
	public let outputValueType: RichValueType = .text

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
