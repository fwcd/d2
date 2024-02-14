public struct ChannelModification {
    public let name: String?
    public let archived: Bool?
    public let locked: Bool?

    public init(
        name: String? = nil,
        archived: Bool? = nil,
        locked: Bool? = nil
    ) {
        self.name = name
        self.archived = archived
        self.locked = locked
    }
}
