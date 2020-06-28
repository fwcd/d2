import D2MessageIO
import D2Utils

fileprivate let allFlag = "--all"
fileprivate let subcommandPattern = try! Regex(from: "^(\\w+)(?:\\s+(.+))?")

public class InventoryCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the user's inventory",
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
            }
        ]
        info.helpText = "Available Subcommands: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))"
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        if let parsedSubcommand = subcommandPattern.firstGroups(in: input) {
            let subcommandName = parsedSubcommand[1]
            let subcommandArgs = parsedSubcommand[2]
            guard let subcommand = subcommands[subcommandName] else {
                output.append(errorText: "No subcommand named `\(subcommandName)`")
                return
            }
            subcommand(subcommandArgs, output, context)
        } else {
            guard let user = context.message.mentions.first ?? context.author else {
                output.append(errorText: "No author available")
                return
            }

            let showAll = input.contains(allFlag)
            let inventory = inventoryManager[user]

            output.append(Embed(
                title: "Inventory for `\(user.username)`",
                fields: inventory.items.map {
                    Embed.Field(name: $0.key, value: Dictionary(grouping: $0.value, by: { $0.id })
                        .filter { showAll || !$0.value.contains { $0.hidden } }
                        .map { "\($0.value.count)x \($0.value.first?.name ?? "?")" }
                        .joined(separator: "\n")
                        .nilIfEmpty ?? "_nothing_")
                }
            ))
        }
    }
}
