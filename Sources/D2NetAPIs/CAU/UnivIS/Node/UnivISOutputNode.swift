public struct UnivISOutputNode: Sendable {
    public let childs: [any UnivISObjectNode]

    public func resolve(ref: UnivISRef) -> (any UnivISObjectNode)? {
        return childs.first { $0.key == ref.key }
    }
}
