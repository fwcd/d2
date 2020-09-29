import Utils

public protocol MessageDelegate {
    func on(connect connected: Bool, client: MessageClient)

    func on(disconnectWithReason reason: String, client: MessageClient)

    func on(createChannel channelId: ChannelID, client: MessageClient)

    func on(deleteChannel channelId: ChannelID, client: MessageClient)

    func on(updateChannel channelId: ChannelID, client: MessageClient)

    func on(createGuild guild: Guild, client: MessageClient)

    func on(deleteGuild guild: Guild, client: MessageClient)

    func on(updateGuild guild: Guild, client: MessageClient)

    func on(addGuildMember member: Guild.Member, client: MessageClient)

    func on(removeGuildMember member: Guild.Member, client: MessageClient)

    func on(updateGuildMember member: Guild.Member, client: MessageClient)

    func on(updateMessage message: Message, client: MessageClient)

    func on(createMessage message: Message, client: MessageClient)

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient)

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient)

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, client: MessageClient)

    func on(createRole role: Role, on guild: Guild, client: MessageClient)

    func on(deleteRole role: Role, from guild: Guild, client: MessageClient)

    func on(updateRole role: Role, on guild: Guild, client: MessageClient)

    func on(receivePresenceUpdate presence: Presence, client: MessageClient)

    func on(receiveReady data: [String: Any], client: MessageClient)

    func on(receiveVoiceStateUpdate state: VoiceState, client: MessageClient)

    func on(handleGuildMemberChunk chunk: LazyDictionary<UserID, Guild.Member>, for guild: Guild, client: MessageClient)

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, client: MessageClient)
}

public extension MessageDelegate {
    func on(connect connected: Bool, client: MessageClient) {}

    func on(disconnectWithReason reason: String, client: MessageClient) {}

    func on(createChannel channelId: ChannelID, client: MessageClient) {}

    func on(deleteChannel channelId: ChannelID, client: MessageClient) {}

    func on(updateChannel channelId: ChannelID, client: MessageClient) {}

    func on(createGuild guild: Guild, client: MessageClient) {}

    func on(deleteGuild guild: Guild, client: MessageClient) {}

    func on(updateGuild guild: Guild, client: MessageClient) {}

    func on(addGuildMember member: Guild.Member, client: MessageClient) {}

    func on(removeGuildMember member: Guild.Member, client: MessageClient) {}

    func on(updateGuildMember member: Guild.Member, client: MessageClient) {}

    func on(updateMessage message: Message, client: MessageClient) {}

    func on(createMessage message: Message, client: MessageClient) {}

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {}

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: MessageClient) {}

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, client: MessageClient) {}

    func on(createRole role: Role, on guild: Guild, client: MessageClient) {}

    func on(deleteRole role: Role, from guild: Guild, client: MessageClient) {}

    func on(updateRole role: Role, on guild: Guild, client: MessageClient) {}

    func on(receivePresenceUpdate presence: Presence, client: MessageClient) {}

    func on(receiveReady data: [String: Any], client: MessageClient) {}

    func on(receiveVoiceStateUpdate state: VoiceState, client: MessageClient) {}

    func on(handleGuildMemberChunk chunk: LazyDictionary<UserID, Guild.Member>, for guild: Guild, client: MessageClient) {}

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, client: MessageClient) {}
}
