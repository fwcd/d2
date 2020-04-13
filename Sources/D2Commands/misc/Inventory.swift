import Foundation

/// A general-purpose key-value store for virtual "items"
/// that a user may acquire. The items are grouped into
/// categories, which may have custom purposes.
public struct Inventory: Hashable, Codable {
    public static let empty = Inventory()

    /// A dictionary holding items by category.
    /// Duplicate items (of the same id) are allowed,
    /// they are generally expected to have the same
    /// name/attributes though.
    public private(set) var items: [String: [Item]]
    
    public init(items: [String: [Item]] = [:]) {
        self.items = items
    }
    
    public struct Item: Hashable, Codable {
        /// A category-specific identifier
        public let id: String
        public let name: String
        public let iconUrl: URL?
        public let attributes: [String: String]
        
        public init(id: String, name: String, iconUrl: URL? = nil, attributes: [String: String] = [:]) {
            self.id = id
            self.name = name
            self.iconUrl = iconUrl
            self.attributes = attributes
        }
    }
    
    public mutating func createIfNotExists(category: String) {
        if items[category] == nil {
            items[category] = []
        }
    }
    
    public mutating func append(item: Item, to category: String) {
        createIfNotExists(category: category)
        items[category]!.append(item)
    }
    
    public mutating func clear(category: String? = nil) {
        if let category = category {
            items[category] = nil
        } else {
            items = [:]
        }
    }
}
