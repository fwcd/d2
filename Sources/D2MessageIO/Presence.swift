import Foundation

public struct PresenceUpdate: Codable {
	public let activity: Activity?
	public let status: PresenceStatus
	public let afkSince: Date?
	
	public init(status: PresenceStatus, activity: Activity? = nil, afkSince: Date? = nil) {
		self.activity = activity
		self.status = status
		self.afkSince = afkSince
	}
	
	public enum PresenceStatus: Int, Codable {
		case idle
		case offline
		case online
		case doNotDisturb
	}
	
	public struct Activity: Codable {
		public let name: String
		public let type: ActivityType
		
		public init(name: String, type: ActivityType) {
			self.name = name
			self.type = type
		}
		
		public enum ActivityType: Int, Codable {
			case game
			case stream
			case listening
		}
	}
}
