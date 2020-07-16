import Foundation

public struct Presence {
	public let guildId: GuildID
	public let user: User
	public let game: Activity?
	public let activities: [Activity]
	public let nick: String?
	public let roles: [String]
	public let status: Presence.Status
	
	public init(guildId: GuildID, user: User, game: Activity? = nil, activities: [Activity] = [], nick: String? = nil, roles: [String] = [], status: Presence.Status) {
		self.guildId = guildId
		self.user = user
		self.game = game
		self.activities = activities
		self.nick = nick
		self.roles = roles
		self.status = status
	}
	
	public struct Activity: Codable {
		public let name: String
		public let assets: Assets?
		public let details: String?
		public let party: Party?
		public let state: String?
		public let timestamps: Timestamps?
		public let type: ActivityType
		public let url: String?
		
		public init(name: String, assets: Assets? = nil, details: String? = nil, party: Party? = nil, state: String? = nil, timestamps: Timestamps? = nil, type: ActivityType, url: String? = nil) {
			self.name = name
			self.assets = assets
			self.details = details
			self.party = party
			self.state = state
			self.timestamps = timestamps
			self.type = type
			self.url = url
		}
		
		public struct Assets: Codable {
			public let largeImage: String?
			public let largeText: String?
			public let smallImage: String?
			public let smallText: String?
			
			public init(largeImage: String? = nil, largeText: String? = nil, smallImage: String? = nil, smallText: String? = nil) {
				self.largeImage = largeImage
				self.largeText = largeText
				self.smallImage = smallImage
				self.smallText = smallText
			}
		}
		
		public struct Party: Codable {
			public let id: String
			public let sizes: [Int]?
			
			public init(id: String, sizes: [Int]? = nil) {
				self.id = id
				self.sizes = sizes
			}
		}
		
		public struct Timestamps: Codable {
			public let start: Date?
			public let end: Date?

			public var interval: TimeInterval? { start.map { (end ?? Date()).timeIntervalSince($0) } }
			
			public init(start: Date? = nil, end: Date? = nil) {
				self.start = start
				self.end = end
			}
		}
		
		public enum ActivityType: Int, Codable {
			case game
			case stream
			case listening
		}
	}
	
	public enum Status: String, Codable {
		case idle = "idle"
		case offline = "offline"
		case online = "online"
		case doNotDisturb = "doNotDisturb"
	}
}

public struct PresenceUpdate: Codable {
	public let game: Presence.Activity?
	public let status: Presence.Status
	public let afkSince: Date?
	
	public init(game: Presence.Activity? = nil, status: Presence.Status = .online, afkSince: Date? = nil) {
		self.game = game
		self.status = status
		self.afkSince = afkSince
	}
}
