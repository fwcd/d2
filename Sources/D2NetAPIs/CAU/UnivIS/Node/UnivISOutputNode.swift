public struct UnivISOutputNode {
    public let childs: [UnivISObjectNode]

    public func resolve(ref: UnivISRef) -> UnivISObjectNode? {
        return childs.first { $0.key == ref.key }
    }
}
