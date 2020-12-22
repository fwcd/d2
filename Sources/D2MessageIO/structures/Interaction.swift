public struct Interaction {
    public let id: InteractionID
    public let type: InteractionType?
    public let data: MIOCommand.InteractionData?
    public let guildId: GuildID?
    public let channelId: ChannelID?
    public let member: Guild.Member?
    public let token: String?
    public let version: Int?

    public init(
        id: InteractionID,
        type: InteractionType? = nil,
        data: MIOCommand.InteractionData? = nil,
        guildId: GuildID? = nil,
        channelId: ChannelID? = nil,
        member: Guild.Member? = nil,
        token: String? = nil,
        version: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.data = data
        self.guildId = guildId
        self.channelId = channelId
        self.member = member
        self.token = token
        self.version = version
    }

    public enum InteractionType {
        case ping
        case mioCommand
    }
}
