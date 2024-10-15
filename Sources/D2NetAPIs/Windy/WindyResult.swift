public struct WindyResult<T> {
    public let status: String
    public let result: T?
}

extension WindyResult: Sendable where T: Sendable {}
extension WindyResult: Encodable where T: Encodable {}
extension WindyResult: Decodable where T: Decodable {}
