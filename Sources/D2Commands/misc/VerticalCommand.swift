import SwiftDiscord
import D2Permissions

public class VerticalCommand: StringCommand {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Converts horizontal to vertical text",
		longDescription: "Inserts newlines between the input characters",
		requiredPermissionLevel: .basic
	)
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		output.append(input.reduce("") { "\($0)\n\($1)" })
	}
}
