public struct UnivISEvent: UnivISObjectNode, Hashable, Sendable {
    public let nodeType = "Event"
    public let key: String
    public var contact: UnivISRef? = nil
    public var dbref: UnivISRef? = nil
    public var enddate: String? = nil
    public var id: UInt? = nil
    public var orgname: String? = nil
    public var orgunits = [String]()
    public var startdate: String? = nil
    public var terms = [UnivISTerm]()
    public var title: String? = nil
    public var shortDescription: String {
        return "\(title ?? "?"): \(startdate.map { "\($0) " } ?? "")\(enddate.flatMap { startdate == $0 ? nil : self }.map { "-> \($0)" } ?? "")"
    }

    public init(key: String) {
        self.key = key
    }
}
