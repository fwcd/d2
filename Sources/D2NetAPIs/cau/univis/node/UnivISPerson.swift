public struct UnivISPerson: UnivISObjectNode, Hashable {
    public let nodeType = "Person"
    public let key: String
    public var atitle: String? = nil
    public var title: String? = nil
    public var firstname: String? = nil
    public var lastname: String? = nil
    public var id: UInt? = nil
    public var lehr: Bool? = nil
    public var locations = [UnivISLocation]()
    public var officehours = [UnivISOfficeHour]()
    public var orgname: String? = nil
    public var orgunits = [String]()
    public var visible: Bool? = nil
    public var shortDescription: String {
        return "\(title.map { "\($0) " } ?? "")\(firstname ?? "") \(lastname ?? "")"
    }

    public init(key: String) {
        self.key = key
    }
}
