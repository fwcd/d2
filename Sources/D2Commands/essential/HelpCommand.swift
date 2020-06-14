import D2MessageIO
import D2Permissions

public class HelpCommand: StringCommand {
	public let info = CommandInfo(
		category: .essential,
		shortDescription: "Helps the user",
		longDescription: "Displays a help embed showing all registered commands",
		requiredPermissionLevel: .basic
	)
	public let outputValueType: RichValueType = .embed
	private let commandPrefix: String
	private let permissionManager: PermissionManager
	
	public init(commandPrefix: String, permissionManager: PermissionManager) {
		self.commandPrefix = commandPrefix
		self.permissionManager = permissionManager
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		if input.isEmpty {
			output.append(generalHelpEmbed(context: context))
		} else {
			if let category = CommandCategory(rawValue: input) {
				output.append(categoryHelpEmbed(for: category, context: context))
			} else if let command = context.registry[input] {
				output.append(commandHelpEmbed(for: input, command: command))
			} else {
				output.append(Embed(
					title: ":warning: Did not recognize command `\(input)`",
					description: "Could not fetch any help"
				))
			}
		}
	}
	
	private func generalHelpEmbed(context: CommandContext) -> Embed {
		let commands = context.registry.commandsWithAliases()
		return Embed(
			title: ":question: Available Commands",
			fields: CommandCategory.allCases
				.map { category in Embed.Field(
					name: "\(category)",
					value: commands
						.filter { $0.command.info.category == category }
						.map { "`\(commandPrefix)\($0.name)`" }
						.joined(separator: ", ")
						+ " (Type `\(commandPrefix)help \(category.rawValue)` for details)"
				) }
		)
	}
	
	private func categoryHelpEmbed(for category: CommandCategory, context: CommandContext) -> Embed {
		guard let author = context.author else {
			return Embed(title: "Message has no author!") // HACK
		}
		let commands = context.registry.commandsWithAliases()
		let helpGroups = Dictionary(grouping: commands.filter { !$0.command.info.hidden && $0.command.info.category == category }, by: { $0.command.info.requiredPermissionLevel })
			.filter { permissionManager[author].rawValue >= $0.key.rawValue }
			.sorted { $0.key.rawValue < $1.key.rawValue }
		let helpFields = helpGroups
			.flatMap { (group: (key: PermissionLevel, value: [CommandRegistry.CommandWithAlias])) -> [Embed.Field] in
				let splitGroups = group.value
					.sorted { $0.name < $1.name }
					.map { """
						**\(commandPrefix)\($0.name)**\($0.aliases.nilIfEmpty.map { " (aka. \($0.joined(separator: ", ")))" } ?? ""): `\($0.command.inputValueType) -> \($0.command.outputValueType)`
						    \($0.command.info.shortDescription)
						
						""" }
					.chunks(ofLength: 14)
				return splitGroups
					.enumerated()
					.map { Embed.Field(name: ":star: \(group.key) commands (\($0.0 + 1)/\(splitGroups.count))", value: $0.1.joined(separator: "\n")) }
			}
		return Embed(
			title: "\(category) | Available Commands",
			fields: helpFields
		)
	}

	private func commandHelpEmbed(for name: String, command: Command) -> Embed {
		return Embed(
			title: ":question: \(commandPrefix)\(name): `\(command.inputValueType) -> \(command.outputValueType)`",
			description: """
				\(command.info.longDescription)
				
				\(command.info.helpText ?? "")
				""".trimmingCharacters(in: .whitespaces),
			footer: Embed.Footer(text: "\(command.info.category)")
		)
	}
}
