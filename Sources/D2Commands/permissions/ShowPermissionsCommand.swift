import SwiftDiscord
import D2Permissions

public class ShowPermissionsCommand: Command {
	public let info = CommandInfo(
		category: .permissions,
		shortDescription: "Displays the configured permissions",
		longDescription: "Outputs all registered user permissions",
		requiredPermissionLevel: .admin
	)
	public let inputValueType: RichValueType = .none
	public let outputValueType: RichValueType = .code
	private let permissionManager: PermissionManager
	
	public init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	public func invoke(input: RichValue, output: CommandOutput, context: CommandContext) {
		output.append(.code("\(permissionManager)", language: nil))
	}
}
