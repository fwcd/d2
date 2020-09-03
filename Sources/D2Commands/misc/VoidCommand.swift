import D2MessageIO
import D2Permissions

public class VoidCommand: Command {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Does nothing",
		longDescription: "Does nothing",
		requiredPermissionLevel: .basic
	)
	public let description = "Does nothing."
	public let inputValueType: RichValueType = .none
	public let outputValueType: RichValueType = .none

	public init() {}

	public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
		// Do nothing
	}
}
