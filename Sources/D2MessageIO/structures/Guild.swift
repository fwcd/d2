import Foundation

// TODO: Make this a protocol and add roles/members properties
public struct Guild: Codable {
	public let id: GuildID
	public let ownerId: UserID
	public let region: String
	public let large: Bool
	public let name: String
	public let joinedAt: Date
	public let splash: String
	public let unavailable: Bool
	public let description: String
	public let mfaLevel: Int
	public let verificationLevel: Int
	public let embedEnabled: Bool
	public let embedChannelId: ChannelID
	public let icon: String
	public let members: [UserID: Member]
	public let roles: [RoleID: Role]
	public let presences: [UserID: Presence]
	public let voiceStates: [UserID: VoiceState]
	public let emojis: [EmojiID: Emoji]
	public let channels: [ChannelID: Channel]
	
	public init(
		id: GuildID,
		ownerId: UserID,
		region: String,
		large: Bool,
		name: String,
		joinedAt: Date,
		splash: String,
		unavailable: Bool,
		description: String,
		mfaLevel: Int,
		verificationLevel: Int,
		embedEnabled: Bool,
		embedChannelId: ChannelID,
		icon: String,
		members: [UserID: Member] = [:],
		roles: [RoleID: Role] = [:],
		presences: [UserID: Presence] = [:],
		voiceStates: [UserID: VoiceState] = [:],
		emojis: [EmojiID: Emoji] = [:],
		channels: [ChannelID: Channel] = [:]
	) {
		self.id = id
		self.ownerId = ownerId
		self.region = region
		self.large = large
		self.name = name
		self.joinedAt = joinedAt
		self.splash = splash
		self.unavailable = unavailable
		self.description = description
		self.mfaLevel = mfaLevel
		self.verificationLevel = verificationLevel
		self.embedEnabled = embedEnabled
		self.embedChannelId = embedChannelId
		self.icon = icon
		self.members = members
		self.roles = roles
		self.presences = presences
		self.voiceStates = voiceStates
		self.emojis = emojis
		self.channels = channels
	}
	
	public struct Channel: Codable {
		public let guildId: GuildID
		public let name: String
		public let parentId: ChannelID?
		public let position: Int
		public let permissionOverwrites: [OverwriteID: PermissionOverwrite]
		
		public init(guildId: GuildID, name: String, parentId: ChannelID? = nil, position: Int, permissionOverwrites: [OverwriteID: PermissionOverwrite] = [:]) {
			self.guildId = guildId
			self.name = name
			self.parentId = parentId
			self.position = position
			self.permissionOverwrites = permissionOverwrites
		}
		
		public struct PermissionOverwrite: Codable {
			public let id: OverwriteID
			public let type: PermissionOverwriteType
			
			public init(id: OverwriteID, type: PermissionOverwriteType) {
				self.id = id
				self.type = type
			}
			
			public enum PermissionOverwriteType: Int, Codable {
				case role
				case member
			}
		}
	}
	
	public struct Member: Codable {
		public let guildId: GuildID
		public let joinedAt: Date
		public let user: User
		public let deaf: Bool
		public let roleIds: [RoleID]
		
		public init(guildId: GuildID, joinedAt: Date, user: User, deaf: Bool, roleIds: [RoleID] = []) {
			self.guildId = guildId
			self.joinedAt = joinedAt
			self.user = user
			self.deaf = deaf
			self.roleIds = roleIds
		}
	}
}
