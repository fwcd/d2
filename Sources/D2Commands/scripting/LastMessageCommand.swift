import D2Permissions

public class LastMessageCommand: Command {
	public let info = CommandInfo(
		category: .scripting,
		shortDescription: "Fetches the last message",
		longDescription: "Retrieves and outputs the last message",
		requiredPermissionLevel: .vip
	)
	public let inputValueType: RichValueType = .none
	public let outputValueType: RichValueType = .any
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		context.client?.getMessages(for: context.channel!.id, limit: 2) { result, _ in
			if let lastMessage = result[safely: 1] {
				MessageParser().parse(message: lastMessage) {
					output.append($0)
				}
			} else {
				output.append(errorText: "Could not find last message.")
			}
		}
	}
}
