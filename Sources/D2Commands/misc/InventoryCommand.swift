import D2MessageIO

public class InventoryCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Fetches the user's inventory",
        requiredPermissionLevel: .basic
    )
    private let inventoryManager: InventoryManager
    
    public init(inventoryManager: InventoryManager) {
        self.inventoryManager = inventoryManager
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let user = context.message.mentions.first ?? context.author else {
            output.append(errorText: "No author available")
            return
        }
        let inventory = inventoryManager[user]
        output.append(Embed(
            title: "Inventory for `\(user.username)`",
            fields: inventory.items.map {
                Embed.Field(name: $0.0, value: Dictionary(grouping: $0.1, by: { $0.id })
                    .map { "\($0.1.count)x \($0.1.first?.name ?? "?")" }
                    .joined(separator: "\n")
                    .nilIfEmpty ?? "_nothing_")
            }
        ))
    }
}
