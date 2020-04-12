/// A general-purpose key-value store for virtual "items"
/// that a user may acquire. The items are grouped into
/// categories, which may have custom purposes.
public struct Inventory: Hashable, Codable {
    public static let empty = Inventory()

    /// A dictionary holding items by category.
    /// Duplicate items (of the same id) are allowed,
    /// they are generally expected to have the same
    /// name/attributes though.
    public var items: [String: [Item]]
    
    public init(items: [String: [Item]] = [:]) {
        self.items = items
    }
    
    public struct Item: Hashable, Codable {
        /// A category-specific identifier
        public let id: String
        public let name: String
        public let iconUrl: String?
        public let attributes: [String: String]
        
        public init(id: String, name: String, iconUrl: String? = nil, attributes: [String: String] = [:]) {
            self.id = id
            self.name = name
            self.iconUrl = iconUrl
            self.attributes = attributes
        }
    }
}
