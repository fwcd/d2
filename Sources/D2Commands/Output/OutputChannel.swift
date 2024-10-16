import D2MessageIO

public enum OutputChannel: Hashable, Sendable {
    case guildChannel(ChannelID)
    case dmChannel(UserID)
    case defaultChannel
}
