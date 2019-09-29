import SwiftDiscord
import D2Permissions

public class HelpCommand: StringCommand {
	public let description = "Helps the user"
	public let outputValueType = "embed"
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
		if input.isEmpty {
			output.append(generalHelpEmbed(context: context))
		} else {
			if let command = context.registry[input] {
				output.append(commandHelpEmbed(for: input, command: command))
			} else {
				output.append(DiscordEmbed(
					title: ":warning: Did not recognize command `\(input)`",
					description: "Could not fetch any help"
				))
			}
		}
	}
	
	private func commandHelpEmbed(for name: String, command: Command) -> DiscordEmbed {
		return DiscordEmbed(
			title: ":question: \(commandPrefix)\(name): `\(command.inputValueType) -> \(command.outputValueType)`",
			description: """
				\(command.description)
				
				\(command.helpText ?? "")
				""".trimmingCharacters(in: .whitespaces)
		)
	}
	
	private func generalHelpEmbed(context: CommandContext) -> DiscordEmbed {
		let helpGroups = Dictionary(grouping: context.registry.filter { !$0.value.hidden }, by: { $0.value.requiredPermissionLevel })
			.filter { permissionManager[context.author].rawValue >= $0.key.rawValue }
			.sorted { $0.key.rawValue < $1.key.rawValue }
		let helpFields = helpGroups
			.flatMap { (group: (key: PermissionLevel, value: [(key: String, value: Command)])) -> [DiscordEmbed.Field] in
				let splitGroups = group.value
					.sorted { $0.key < $1.key }
					.map { """
						**\(commandPrefix)\($0.key)**: `\($0.value.inputValueType) -> \($0.value.outputValueType)`
						    \($0.value.description)
						
						""" }
					.chunks(ofLength: 14)
				return splitGroups
					.enumerated()
					.map { DiscordEmbed.Field(name: ":star: \(group.key) commands (\($0.0 + 1)/\(splitGroups.count))", value: $0.1.joined(separator: "\n")) }
			}
		return DiscordEmbed(
			title: ":question: Available Commands",
			fields: helpFields
		)
	}
}
