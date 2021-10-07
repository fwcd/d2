public struct Interaction {
    public let id: InteractionID
    public let type: InteractionType?
    public let customId: String?
    public let data: InteractionData?
    public let guildId: GuildID?
    public let channelId: ChannelID?
    public let member: Guild.Member?
    public let message: Message?
    public let token: String?
    public let version: Int?

    public init(
        id: InteractionID,
        type: InteractionType? = nil,
        customId: String? = nil,
        data: InteractionData? = nil,
        guildId: GuildID? = nil,
        channelId: ChannelID? = nil,
        member: Guild.Member? = nil,
        message: Message? = nil,
        token: String? = nil,
        version: Int? = nil
    ) {
        self.id = id
        self.type = type
        self.customId = customId
        self.data = data
        self.guildId = guildId
        self.channelId = channelId
        self.member = member
        self.message = message
        self.token = token
        self.version = version
    }

    public enum InteractionType {
        case ping
        case mioCommand
        case messageComponent
    }

    public struct InteractionData {
        public let id: MIOCommandID?
        public let name: String
        public let customId: String?
        public let options: [Option]

        public init(
            id: MIOCommandID? = nil,
            name: String = "",
            customId: String? = nil,
            options: [Option] = []
        ) {
            self.id = id
            self.name = name
            self.customId = customId
            self.options = options
        }

        public struct Option {
            public let name: String
            public let value: Any?
            public let options: [Option]

            public init(
                name: String,
                value: Any? = nil,
                options: [Option] = []
            ) {
                self.name = name
                self.value = value
                self.options = options
            }
        }
    }
}
