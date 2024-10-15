public struct WindyResult<T>: Codable where T: Sendable, Codable {
    public let status: String
    public let result: T?
}
