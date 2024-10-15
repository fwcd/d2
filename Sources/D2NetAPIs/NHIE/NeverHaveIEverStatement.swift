public struct NeverHaveIEverStatement: Sendable, Codable {
    public let statement: String
    public let category: String?

    public init(statement: String, category: String? = nil) {
        self.statement = statement
        self.category = category
    }
}
