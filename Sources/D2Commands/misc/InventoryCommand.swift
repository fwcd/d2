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
                Embed.Field(name: $0.key, value: Dictionary(grouping: $0.value, by: { $0.id })
                    .filter { !$0.value.contains { $0.hidden } }
                    .map { "\($0.value.count)x \($0.value.first?.name ?? "?")" }
                    .joined(separator: "\n")
                    .nilIfEmpty ?? "_nothing_")
            }
        ))
    }
}
