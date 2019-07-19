import D2Permissions

public class PingCommand: Command {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Replies with 'Pong!'",
		longDescription: "Outputs 'Pong!'",
		requiredPermissionLevel: .basic
	)
	public let inputValueType: RichValueType = .none
	public let outputValueType: RichValueType = .text
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		output.append("Pong!")
	}
}
