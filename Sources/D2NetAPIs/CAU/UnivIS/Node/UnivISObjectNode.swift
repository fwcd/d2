public protocol UnivISObjectNode: Sendable {
    var nodeType: String { get }
    var shortDescription: String { get }
    var key: String { get }
}
