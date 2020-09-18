public struct UnivISTitle: UnivISObjectNode, Hashable {
    public let nodeType = "Title"
    public let key: String
    public var title: String? = nil
    public var titleEn: String? = nil
    public var ordernr: Int? = nil
    public var parentTitle: UnivISRef? = nil
    public var text: String? = nil
    public var shortDescription: String {
        return "\(title ?? "?"): \(text ?? "?")"
    }

    public init(key: String) {
        self.key = key
    }
}
