public struct VoiceState {
    public let channelId: ChannelID?
    public let guildId: GuildID?
    public let userId: UserID
    public let deaf: Bool
    public let mute: Bool
    public let selfDeaf: Bool
    public let selfMute: Bool
    public let suppress: Bool

    public init(
        channelId: ChannelID? = nil,
        guildId: GuildID? = nil,
        userId: UserID,
        deaf: Bool,
        mute: Bool,
        selfDeaf: Bool,
        selfMute: Bool,
        suppress: Bool
    ) {
        self.channelId = channelId
        self.guildId = guildId
        self.userId = userId
        self.deaf = deaf
        self.mute = mute
        self.selfDeaf = selfDeaf
        self.selfMute = selfMute
        self.suppress = suppress
    }
}
