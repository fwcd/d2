public struct WindyResult<T>: Codable where T: Codable {
    public let status: String
    public let result: T?
}
