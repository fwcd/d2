import SwiftDiscord
import D2Permissions

public class HelpCommand: StringCommand {
	public let description = "Helps the user"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let commandPrefix: String
	private let permissionManager: PermissionManager
	
	public init(commandPrefix: String, permissionManager: PermissionManager) {
		self.commandPrefix = commandPrefix
		self.permissionManager = permissionManager
	}
	
	// TODO: Integrate new 'helpText' API
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		let helpGroups = Dictionary(grouping: context.registry.filter { !$0.value.hidden }, by: { $0.value.requiredPermissionLevel })
			.filter { permissionManager[context.author].rawValue >= $0.key.rawValue }
			.sorted { $0.key.rawValue < $1.key.rawValue }
		let helpFields = helpGroups
			.flatMap { (group: (key: PermissionLevel, value: [(key: String, value: Command)])) -> [DiscordEmbed.Field] in
				let splitGroups = group.value
					.sorted { $0.key < $1.key }
					.map { """
						**\(commandPrefix)\($0.key)**: \($0.value.inputValueType) -> \($0.value.outputValueType)
						    \($0.value.description)
						
						""" }
					.chunks(ofLength: 14)
				return splitGroups
					.enumerated()
					.map { DiscordEmbed.Field(name: ":star: \(group.key) commands (\($0.0 + 1)/\(splitGroups.count))", value: $0.1.joined(separator: "\n")) }
			}
		output.append(DiscordEmbed(
			title: ":question: Available Commands",
			fields: helpFields
		))
	}
}
