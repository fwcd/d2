public struct UnivISLecture: UnivISObjectNode, Hashable {
    public let nodeType = "Lecture"
    public let key: String
    public var classification: UnivISRef? = nil
    public var dozs = [UnivISRef]()
    public var id: Int? = nil
    public var name: String? = nil
    public var number: Int? = nil
    public var ordernr: Int? = nil
    public var orgname: String? = nil
    public var orgunits = [String]()
    public var sws: Int? = nil
    public var terms = [UnivISTerm]()
    public var type: String? = nil
    public var parentLv: UnivISRef?
    public var short: String? = nil
    public var startdate: String? = nil
    public var enddate: String? = nil
    public var turnout: Int? = nil
    public var ects: Bool? = nil
    public var ectsCred: Int? = nil
    public var literature: String? = nil
    public var organizational: String? = nil
    public var evaluation: Bool? = nil
    public var summary: String? = nil
    public var shortDescription: String {
        return "\(name ?? "?"): \(startdate.map { "\($0) " } ?? "")\(enddate.map { "-> \($0)" } ?? "")"
    }

    public init(key: String) {
        self.key = key
    }
}
