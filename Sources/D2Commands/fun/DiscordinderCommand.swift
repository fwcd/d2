fileprivate let inventoryCategory = "Discordinder Matches"

public class DiscordinderCommand: StringCommand {
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
        guard let authorId = context.author?.id else {
            output.append(errorText: "Author has no user ID")
            return
        }

        var inventory = inventoryManager[authorId]
        // TODO
        inventoryManager[authorId] = inventory
    }
}
