public struct UnivISRoom: UnivISObjectNode, Hashable, Sendable {
    public let nodeType = "Room"
    public let key: String
    public var address: String? = nil
    public var chtab: Bool? = nil
    public var contacts = [UnivISRef]()
    public var description: String? = nil
    public var id: UInt? = nil
    public var inet: Bool? = nil
    public var beam: Bool? = nil
    public var dark: Bool? = nil
    public var lose: Bool? = nil
    public var ohead: Bool? = nil
    public var wlan: Bool? = nil
    public var tafel: Bool? = nil
    public var laptopton: Bool? = nil
    public var fest: Bool? = nil
    public var tel: String? = nil
    public var name: String? = nil
    public var orgname: String? = nil
    public var orgunits = [String]()
    public var rolli: Bool? = nil
    public var short: String? = nil
    public var size: Int? = nil
    public var wb: Bool? = nil
    public var shortDescription: String {
        return "\(name ?? "?"): \(address ?? "?")"
    }

    public init(key: String) {
        self.key = key
    }
}
