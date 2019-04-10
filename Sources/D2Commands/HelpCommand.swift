import SwiftDiscord
import D2Permissions

public class HelpCommand: StringCommand {
	public let description = "Helps the user"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let permissionManager: PermissionManager
	
	public init(permissionManager: PermissionManager) {
		self.permissionManager = permissionManager
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		let helpGroups = Dictionary(grouping: context.registry.filter { !$0.value.hidden }, by: { $0.value.requiredPermissionLevel })
			.filter { permissionManager[context.author].rawValue >= $0.key.rawValue }
			.sorted { $0.key.rawValue < $1.key.rawValue }
		let helpFields = helpGroups
			.map { (group: (key: PermissionLevel, value: [(key: String, value: Command)])) -> DiscordEmbed.Field in
				let commandDescriptions = group.value
					.sorted { $0.key < $1.key }
					.map { "**\($0.key)**:  \($0.value.description)" }
					.joined(separator: "\n")
				return DiscordEmbed.Field(name: ":star: \(group.key)", value: commandDescriptions)
			}
		output.append(DiscordEmbed(
			title: "Available Commands",
			fields: helpFields
		))
	}
}
