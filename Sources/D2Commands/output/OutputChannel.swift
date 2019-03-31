import SwiftDiscord

public enum OutputChannel {
	case serverChannel(ChannelID)
	case userChannel(UserID)
	case defaultChannel
}
