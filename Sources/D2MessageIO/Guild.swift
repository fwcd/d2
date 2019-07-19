import Foundation

public struct Guild: Codable {
	public let id: GuildID
	public let large: Bool
	public let joinedAt: Date
	public let splash: String
	public let unavailable: Bool
	public let description: String
	public let channels: [ChannelID: GuildChannel]
	
	public init(id: GuildID, large: Bool, joinedAt: Date, splash: String, unavailable: Bool, description: String, channels: [ChannelID: GuildChannel] = [:]) {
		self.id = id
		self.large = large
		self.joinedAt = joinedAt
		self.splash = splash
		self.unavailable = unavailable
		self.description = description
		self.channels = channels
	}
	
	public struct GuildChannel: Codable {
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
}
