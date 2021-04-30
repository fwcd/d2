import D2MessageIO

public enum OutputChannel: Hashable {
    case guildChannel(ChannelID)
    case dmChannel(UserID)
    case defaultChannel
}
