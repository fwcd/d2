import D2MessageIO

public enum OutputChannel {
    case guildChannel(ChannelID)
    case dmChannel(UserID)
    case defaultChannel
}
