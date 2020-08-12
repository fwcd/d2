import D2MessageIO
import D2Permissions
import D2Utils

public class SearchCommand: StringCommand {
    public let info = CommandInfo(
        category: .meta,
        shortDescription: "Searches for available commands",
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
        let term = input.lowercased()
        guard !term.isEmpty else {
            output.append(errorText: "Please enter a search term!")
            return
        }

        do {
            let parsedPattern = try? Regex(from: term)
            let pattern = try parsedPattern ?? Regex(from: Regex.escape(term))
            let results = context.registry
                .commandsWithAliases()
                .filter {
                    let info = $0.command.info
                    let names = [$0.name, info.shortDescription, info.longDescription, "\($0.command.inputValueType) -> \($0.command.outputValueType)"] + $0.aliases
                    return names
                        .map { $0.lowercased() }
                        .contains { pattern.matchCount(in: $0) > 0 }
                }
                .sorted(by: descendingComparator { $0.name.levenshteinDistance(to: input) })
                .prefix(5)

            output.append(Embed(
                title: ":mag: Found Commands",
                fields: results.map { Embed.Field(
                    name: "`\(commandPrefix)\($0.name)`\($0.aliases.nilIfEmpty.map { " (aka. \($0.map { "`\($0)`" }.joined(separator: ", ")))" } ?? "")",
                    value: $0.command.info.longDescription
                ) }
            ))
        } catch {
            output.append(errorText: "Invalid input: `\(input)`")
        }
    }
}
