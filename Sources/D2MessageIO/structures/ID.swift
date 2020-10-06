import Utils

public typealias ChannelID = ID
public typealias MessageID = ID
public typealias AttachmentID = ID
public typealias UserID = ID
public typealias RoleID = ID
public typealias EmojiID = ID
public typealias GuildID = ID
public typealias OverwriteID = ID

public let dummyId: ID = ID("")

/**
 * A container for a type-erased ID.
 */
public struct ID: Hashable, Codable, LosslessStringConvertible {
    public let value: String
    public let clientName: String

    public var description: String { "\(value)" }

    public init(_ value: String) {
        self.init(value, clientName: "Dummy")
    }

    public init(_ value: String, clientName: String) {
        self.value = value
        self.clientName = clientName
    }
}
