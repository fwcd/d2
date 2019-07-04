public struct PresenceUpdate {
	public let activity: Activity?
	public let status: Status?
	
	public init(activity: Activity?, status: Status?) {
		self.activity = activity
		self.status = status
	}
	
	public enum Status {
		case online
		case afk
		case dnd
		case offline
	}
	
	public enum ActivityType {
		case playing
		case listening
	}
	
	public struct Activity {
		public let name: String
		public let type: ActivityType
	}
}
