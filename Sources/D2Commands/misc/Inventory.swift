import Foundation
import Utils

/// A general-purpose key-value store for virtual "items"
/// that a user may acquire. The items are grouped into
/// categories, which may have custom purposes.
public struct Inventory: Hashable, Codable, Sequence {
    public static let empty = Inventory()

    /// A dictionary holding items by category.
    /// Duplicate items (of the same id) are allowed,
    /// they are generally expected to have the same
    /// name/attributes though.
    public private(set) var items: [String: [Item]]

    public init(items: [String: [Item]] = [:]) {
        self.items = items
    }

    public struct Item: Hashable, Codable, CustomStringConvertible {
        /// A category-specific identifier
        public let id: String
        public let name: String
        public let hidden: Bool
        public let iconUrl: URL?
        public let attributes: [String: String]

        public var description: String { "\(name) (#\(id))" }

        public init(id: String, name: String, hidden: Bool = false, iconUrl: URL? = nil, attributes: [String: String] = [:]) {
            self.id = id
            self.name = name
            self.hidden = hidden
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

    public func category(of item: Item) -> String? {
        return items.first { $0.1.contains(item) }.map { $0.0 }
    }

    public mutating func remove(item: Item, from category: String? = nil) {
        guard let c = category ?? self.category(of: item) else { return }
        items[c]?.removeFirst(value: item)
    }

    public mutating func removeAll(from category: String, where predicate: (Inventory.Item) -> Bool) {
        items[category] = items[category]?.filter { !predicate($0) }
    }

    public mutating func clear(category: String? = nil) {
        if let c = category {
            items[c] = nil
        } else {
            items = [:]
        }
    }

    public func makeIterator() -> AnySequence<(String, Item)>.Iterator {
        return AnySequence(items.lazy.flatMap { (c, its) in its.map { (c, $0) } }).makeIterator()
    }
}
