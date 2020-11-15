import D2MessageIO
import D2Permissions
import Utils

public class HelpCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
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

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        let authorLevel = context.author.map { permissionManager[simulated: $0] ?? permissionManager[$0] } ?? PermissionLevel.basic
        if input.isEmpty {
            if Int.random(in: 0..<1000) == 0 {
                output.append("https://www.youtube.com/watch?v=2Q_ZzBGPdqE") // easter egg
            } else {
                output.append(generalHelpEmbed(at: authorLevel, context: context))
            }
        } else {
            if let category = CommandCategory(rawValue: input) {
                output.append(categoryHelpEmbed(for: category, at: authorLevel, context: context))
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

    private func generalHelpEmbed(at authorLevel: PermissionLevel, context: CommandContext) -> Embed {
        let commands = context.registry.commandsWithAliases()
        return Embed(
            title: ":question: Available Commands",
            footer: Embed.Footer(text: "Hint: You can use \(commandPrefix)search to find the command you need!"),
            fields: CommandCategory.allCases
                .compactMap { category in
                    guard let categoryCommands = commands
                        .filter({ $0.command.info.category == category && !$0.command.info.hidden && $0.command.info.requiredPermissionLevel <= authorLevel })
                        .nilIfEmpty else { return nil }

                    return Embed.Field(
                        name: "\(category)",
                        value: "► **\(commandPrefix)help \(category.rawValue)** ```\n" + categoryCommands
                            .map { "\(commandPrefix)\($0.name)" }
                            .truncated(to: 4) { "and \($0.count) more..." }
                            .joined(separator: "\n") + "\n```",
                        inline: true
                    )
                }
        )
    }

    private func categoryHelpEmbed(for category: CommandCategory, at authorLevel: PermissionLevel, context: CommandContext) -> Embed {
        let commands = context.registry.commandsWithAliases()
        let helpGroups = Dictionary(grouping: commands.filter { !$0.command.info.hidden && $0.command.info.category == category }, by: { $0.command.info.requiredPermissionLevel })
            .filter { $0.key <= authorLevel }
            .sorted { $0.key < $1.key }
        let helpFields = helpGroups
            .flatMap { (group: (key: PermissionLevel, value: [CommandRegistry.CommandWithAlias])) -> [Embed.Field] in
                let splitGroups = group.value
                    .sorted { $0.name < $1.name }
                    .map { "**\(commandPrefix)\($0.name)**: \($0.aliases.nilIfEmpty.map { " (aka. `\($0.sorted().joined(separator: ", "))`)" } ?? "") \($0.command.info.shortDescription)" }
                    .chunks(ofLength: 10)
                return splitGroups
                    .enumerated()
                    .map { Embed.Field(name: ":star: \("\(group.key)".withFirstUppercased) Commands (\($0.0 + 1)/\(splitGroups.count))", value: $0.1.joined(separator: "\n")) }
            }
        return Embed(
            title: "\(category) | Available Commands",
            footer: Embed.Footer(text: "Hint: You can use \(commandPrefix)help [commandname] to get help for an individual command!"),
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
