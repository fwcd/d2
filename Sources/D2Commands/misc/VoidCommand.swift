import SwiftDiscord
import D2Permissions

public class VoidCommand: Command {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Does nothing",
		longDescription: "Does nothing",
		requiredPermissionLevel: .basic
	)
	public let description = "Does nothing."
	public let inputValueType = .none
	public let outputValueType = .none
	
	public init() {}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		// Do nothing
	}
}
