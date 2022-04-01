import D2MessageIO
import Utils

fileprivate let allFlag = "--all"
fileprivate let rawMentionPattern = "<[^>]+>"
fileprivate let subcommandPattern = try! Regex(from: "^(?:\(rawMentionPattern))?\\s*(\\w+)(?:\\s+(.+))?")

public class InventoryCommand: Command {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the user's inventory",
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let inventoryManager: InventoryManager
    private var subcommands: [String: (User, String, CommandOutput, CommandContext) -> Void] = [:]

    public init(inventoryManager: InventoryManager) {
        self.inventoryManager = inventoryManager
        subcommands = [
            "clear": { user, input, output, context in
                guard let author = context.author else {
                    output.append(errorText: "No author available")
                    return
                }
                guard author.id == user.id else {
                    output.append(errorText: "You can only clear your own inventory categories!")
                    return
                }
                guard !input.isEmpty else {
                    output.append(errorText: "Please name a category!")
                    return
                }

                var inventory = inventoryManager[user.id]
                inventory.clear(category: input)
                inventoryManager[user.id] = inventory

                output.append("Successfully cleared the category `\(input)`!")
            },
            "show": { user, input, output, context in
                guard !input.isEmpty else {
                    output.append(errorText: "Please name a category!")
                    return
                }

                let inventory = inventoryManager[user.id]
                let category = input.withFirstUppercased // Category names are capitalized by convention
                let items = inventory.items[category] ?? []

                output.append(Embed(
                    title: "Inventory for `\(user.username)` - \(category)",
                    fields: items
                        .filter { !$0.hidden }
                        .suffix(25) // Take the most recent items
                        .map { Embed.Field(name: $0.name, value: $0.attributes.values.joined(separator: "\n").nilIfEmpty ?? "_no attributes_", inline: true) }
                ))
            }
        ]
        info.helpText = """
            Syntax: `[@user]? [subcommand]? [category]?`
            Available Subcommands: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))
            """
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) {
        guard let user = input.asMentions?.first ?? context.author else {
            output.append(errorText: "Mention someone or enter a subcommand to get started!")
            return
        }

        let text = input.asText ?? ""

        if let parsedSubcommand = subcommandPattern.firstGroups(in: text), let subcommand = subcommands[parsedSubcommand[1]] {
            subcommand(user, parsedSubcommand[2], output, context)
        } else {
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
