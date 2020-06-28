fileprivate let inventoryCategory = "Discordinder"

public class DiscordinderCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Play a matching game with other people on the server!",
        requiredPermissionLevel: .basic
    )
    private let inventoryManager: InventoryManager
    
    public init(inventoryManager: InventoryManager) {
        self.inventoryManager = inventoryManager
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        // TODO
    }
}
