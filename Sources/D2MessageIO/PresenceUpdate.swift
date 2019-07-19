public struct PresenceUpdate: Codable {
	public let activity: Activity?
	public let status: Status?
	
	public init(activity: Activity?, status: Status?) {
		self.activity = activity
		self.status = status
	}
	
	public enum Status: String, Codable {
		case online
		case afk
		case dnd
		case offline
	}
	
	public enum ActivityType: String, Codable {
		case playing
		case listening
	}
	
	public struct Activity: Codable {
		public let name: String
		public let type: ActivityType
	}
}
