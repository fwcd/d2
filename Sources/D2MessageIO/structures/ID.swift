import D2Utils

public typealias ChannelID = ID
public typealias MessageID = ID
public typealias AttachmentID = ID
public typealias UserID = ID
public typealias RoleID = ID
public typealias EmojiID = ID
public typealias GuildID = ID
public typealias OverwriteID = ID

public let dummyId: ID = ID(0, clientName: "Dummy")

/**
 * A container for a type-erased ID.
 */
public struct ID: Hashable, Codable, CustomStringConvertible {
	public let value: AnyCodable
	public let clientName: String
	
	public var description: String { "\(value)" }
	
	public init<Value: Codable & Hashable>(_ value: Value, clientName: String) {
		self.value = AnyCodable(value)
		self.clientName = clientName
	}
	
	public func base<T>(as: T.Type) -> T { value.base(as: T.self) }
}
