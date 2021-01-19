import D2MessageIO
import Utils

fileprivate let allFlag = "--all"
fileprivate let subcommandPattern = try! Regex(from: "^(\\w+)(?:\\s+(.+))?")

public class InventoryCommand: Command {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the user's inventory",
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let inventoryManager: InventoryManager
    private var subcommands: [String: (String, CommandOutput, CommandContext) -> Void] = [:]

    public init(inventoryManager: InventoryManager) {
        self.inventoryManager = inventoryManager
        subcommands = [
            "clear": { input, output, context in
                guard let author = context.author else {
                    output.append(errorText: "No author available")
                    return
                }
                guard !input.isEmpty else {
                    output.append(errorText: "Please name a category!")
                    return
                }

                var inventory = inventoryManager[author.id]
                inventory.clear(category: input)
                inventoryManager[author.id] = inventory

                output.append("Successfully cleared the category `\(input)`!")
            },
            "show": { input, output, context in
                guard let author = context.author else {
                    output.append(errorText: "No author available")
                    return
                }
                guard !input.isEmpty else {
                    output.append(errorText: "Please name a category!")
                    return
                }

                let inventory = inventoryManager[author.id]
                let category = input.withFirstUppercased // Category names are capitalized by convention
                let items = inventory.items[category] ?? []

                output.append(Embed(
                    title: "Inventory for `\(author.username)` - \(category)",
                    fields: items
                        .suffix(25) // Take the most recent items
                        .map { Embed.Field(name: $0.name, value: $0.attributes.values.joined(separator: "\n").nilIfEmpty ?? "_no attributes_", inline: true) }
                ))
            }
        ]
        info.helpText = "Available Subcommands: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))"
    }

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        let text = input.asText ?? ""
        if let parsedSubcommand = subcommandPattern.firstGroups(in: text), let subcommand = subcommands[parsedSubcommand[1]] {
            subcommand(parsedSubcommand[2], output, context)
        } else {
            guard let user = input.asMentions?.first ?? context.author else {
                output.append(errorText: "Mention someone or enter a subcommand to get started!")
                return
            }

            let showAll = text.contains(allFlag)
            let inventory = inventoryManager[user]

            output.append(Embed(
                title: "Inventory for `\(user.username)`",
                fields: inventory.items.map {
                    Embed.Field(name: $0.key, value: Dictionary(grouping: $0.value, by: { $0.name })
                        .filter { showAll || !$0.value.contains { $0.hidden } }
                        .map { "\($0.value.count)x \($0.key)" }
                        .joined(separator: "\n")
                        .nilIfEmpty ?? "_nothing_")
                }
            ))
        }
    }
}
