public struct StackOverflowResults<T: Codable>: Sendable, Codable {
    public var items: [T]?
}
