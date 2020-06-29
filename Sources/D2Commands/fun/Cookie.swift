public struct Cookie {
    public let name: String
    public let emoji: String

    public init(name: String, emoji: String = "cookie") {
        self.name = name
        self.emoji = emoji
    }
}

extension Inventory.Item {
    init(fromCookie cookie: Cookie) {
        self.init(id: cookie.name, name: cookie.name)
    }
}
