import SwiftDiscord
import D2Permissions

public class ShowPermissionsCommand: Command {
	public let info = CommandInfo(
		category: .permissions,
		shortDescription: "Displays the configured permissions",
		longDescription: "Outputs all registered user permissions",
		requiredPermissionLevel: .admin
	)
	public let inputValueType = .none
	public let outputValueType = .text
	private let permissionManager: PermissionManager
	
	public init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		output.append("```\n\(permissionManager)\n```")
	}
}
