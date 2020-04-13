import D2Utils
import D2MessageIO

public class InventoryManager {
    @AutoSerializing(filePath: "local/userInventories.json") private var inventories: [UserID: Inventory] = [:]
    
    public init() {}
    
    public subscript(userId: UserID) -> Inventory {
        get { inventories[userId] ?? .empty }
        set { inventories[userId] = newValue }
    }
    
    public subscript(user: User) -> Inventory {
        get { inventories[user.id] ?? .empty }
        set { inventories[user.id] = newValue }
    }
}
