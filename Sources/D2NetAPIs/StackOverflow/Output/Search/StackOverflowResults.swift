public struct StackOverflowResults<T> {
    public var items: [T]?
}

extension StackOverflowResults: Sendable where T: Sendable {}
extension StackOverflowResults: Encodable where T: Encodable {}
extension StackOverflowResults: Decodable where T: Decodable {}
