public typealias ChannelID = ID
public typealias MessageID = ID
public typealias AttachmentID = ID
public typealias UserID = ID
public typealias RoleID = ID
public typealias EmojiID = ID
public typealias GuildID = ID
public typealias OverwriteID = ID

public struct ID: Hashable, Codable {
	public let rawValue: UInt64
	
	public init(_ rawValue: UInt64) {
		self.rawValue = rawValue
	}
}
