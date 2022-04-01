import Utils

/// A handler for events from the message backend.
public protocol MessageDelegate {
    func on(connect connected: Bool, client: any MessageClient)

    func on(disconnectWithReason reason: String, client: any MessageClient)

    func on(createChannel channel: Channel, client: any MessageClient)

    func on(deleteChannel channel: Channel, client: any MessageClient)

    func on(updateChannel channel: Channel, client: any MessageClient)

    func on(createThread thread: Channel, client: any MessageClient)

    func on(deleteThread thread: Channel, client: any MessageClient)

    func on(updateThread thread: Channel, client: any MessageClient)

    func on(createGuild guild: Guild, client: any MessageClient)

    func on(deleteGuild guild: Guild, client: any MessageClient)

    func on(updateGuild guild: Guild, client: any MessageClient)

    func on(addGuildMember member: Guild.Member, client: any MessageClient)

    func on(removeGuildMember member: Guild.Member, client: any MessageClient)

    func on(updateGuildMember member: Guild.Member, client: any MessageClient)

    func on(updateMessage message: Message, client: any MessageClient)

    func on(createMessage message: Message, client: any MessageClient)

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageClient)

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageClient)

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, client: any MessageClient)

    func on(createRole role: Role, on guild: Guild, client: any MessageClient)

    func on(deleteRole role: Role, from guild: Guild, client: any MessageClient)

    func on(updateRole role: Role, on guild: Guild, client: any MessageClient)

    func on(receivePresenceUpdate presence: Presence, client: any MessageClient)

    func on(createInteraction interaction: Interaction, client: any MessageClient)

    func on(receiveReady data: [String: Any], client: any MessageClient)

    func on(receiveVoiceStateUpdate state: VoiceState, client: any MessageClient)

    func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, client: any MessageClient)

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, client: any MessageClient)
}

public extension MessageDelegate {
    func on(connect connected: Bool, client: any MessageClient) {}

    func on(disconnectWithReason reason: String, client: any MessageClient) {}

    func on(createChannel channel: Channel, client: any MessageClient) {}

    func on(deleteChannel channel: Channel, client: any MessageClient) {}

    func on(updateChannel channel: Channel, client: any MessageClient) {}

    func on(createThread thread: Channel, client: any MessageClient) {}

    func on(deleteThread thread: Channel, client: any MessageClient) {}

    func on(updateThread thread: Channel, client: any MessageClient) {}

    func on(createGuild guild: Guild, client: any MessageClient) {}

    func on(deleteGuild guild: Guild, client: any MessageClient) {}

    func on(updateGuild guild: Guild, client: any MessageClient) {}

    func on(addGuildMember member: Guild.Member, client: any MessageClient) {}

    func on(removeGuildMember member: Guild.Member, client: any MessageClient) {}

    func on(updateGuildMember member: Guild.Member, client: any MessageClient) {}

    func on(updateMessage message: Message, client: any MessageClient) {}

    func on(createMessage message: Message, client: any MessageClient) {}

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageClient) {}

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageClient) {}

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, client: any MessageClient) {}

    func on(createRole role: Role, on guild: Guild, client: any MessageClient) {}

    func on(deleteRole role: Role, from guild: Guild, client: any MessageClient) {}

    func on(updateRole role: Role, on guild: Guild, client: any MessageClient) {}

    func on(receivePresenceUpdate presence: Presence, client: any MessageClient) {}

    func on(createInteraction interaction: Interaction, client: any MessageClient) {}

    func on(receiveReady data: [String: Any], client: any MessageClient) {}

    func on(receiveVoiceStateUpdate state: VoiceState, client: any MessageClient) {}

    func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, client: any MessageClient) {}

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, client: any MessageClient) {}
}
