import D2MessageIO

public enum OutputChannel {
	case guildChannel(ChannelID)
	case userChannel(UserID)
	case defaultChannel
}
