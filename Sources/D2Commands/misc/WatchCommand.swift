import D2MessageIO
import D2Permissions

public class WatchCommand: Command {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Outputs the YouTube link given a video ID",
		longDescription: "Constructs the YouTube video link from an ID",
		requiredPermissionLevel: .basic
	)
    public let inputValueType: RichValueType = .mentions
	public let outputValueType: RichValueType = .text

	public init() {}

	public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
		if let mention = input.asMentions?.first {
			let member = context.guild?.members[mention.id]
			output.append(self.urlWith(id: member?.nick ?? ""))
		} else {
			let id = input.asText ?? ""
			output.append(urlWith(id: id))
		}
	}

	private func urlWith(id: String) -> String {
		return "https://youtube.com/watch?v=\(id)"
	}
}
