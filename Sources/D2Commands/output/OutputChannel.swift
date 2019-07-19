import D2MessageIO

public enum OutputChannel {
	case serverChannel(ChannelID)
	case userChannel(UserID)
	case defaultChannel
}
