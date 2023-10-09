import Utils

/// A handler for events from the message backend.
public protocol MessageDelegate {
    func on(connect connected: Bool, client: any Sink)

    func on(disconnectWithReason reason: String, client: any Sink)

    func on(createChannel channel: Channel, client: any Sink)

    func on(deleteChannel channel: Channel, client: any Sink)

    func on(updateChannel channel: Channel, client: any Sink)

    func on(createThread thread: Channel, client: any Sink)

    func on(deleteThread thread: Channel, client: any Sink)

    func on(updateThread thread: Channel, client: any Sink)

    func on(createGuild guild: Guild, client: any Sink)

    func on(deleteGuild guild: Guild, client: any Sink)

    func on(updateGuild guild: Guild, client: any Sink)

    func on(addGuildMember member: Guild.Member, client: any Sink)

    func on(removeGuildMember member: Guild.Member, client: any Sink)

    func on(updateGuildMember member: Guild.Member, client: any Sink)

    func on(updateMessage message: Message, client: any Sink)

    func on(createMessage message: Message, client: any Sink)

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any Sink)

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any Sink)

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, client: any Sink)

    func on(createRole role: Role, on guild: Guild, client: any Sink)

    func on(deleteRole role: Role, from guild: Guild, client: any Sink)

    func on(updateRole role: Role, on guild: Guild, client: any Sink)

    func on(receivePresenceUpdate presence: Presence, client: any Sink)

    func on(createInteraction interaction: Interaction, client: any Sink)

    func on(receiveReady data: [String: Any], client: any Sink)

    func on(receiveVoiceStateUpdate state: VoiceState, client: any Sink)

    func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, client: any Sink)

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, client: any Sink)
}

public extension MessageDelegate {
    func on(connect connected: Bool, client: any Sink) {}

    func on(disconnectWithReason reason: String, client: any Sink) {}

    func on(createChannel channel: Channel, client: any Sink) {}

    func on(deleteChannel channel: Channel, client: any Sink) {}

    func on(updateChannel channel: Channel, client: any Sink) {}

    func on(createThread thread: Channel, client: any Sink) {}

    func on(deleteThread thread: Channel, client: any Sink) {}

    func on(updateThread thread: Channel, client: any Sink) {}

    func on(createGuild guild: Guild, client: any Sink) {}

    func on(deleteGuild guild: Guild, client: any Sink) {}

    func on(updateGuild guild: Guild, client: any Sink) {}

    func on(addGuildMember member: Guild.Member, client: any Sink) {}

    func on(removeGuildMember member: Guild.Member, client: any Sink) {}

    func on(updateGuildMember member: Guild.Member, client: any Sink) {}

    func on(updateMessage message: Message, client: any Sink) {}

    func on(createMessage message: Message, client: any Sink) {}

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any Sink) {}

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any Sink) {}

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, client: any Sink) {}

    func on(createRole role: Role, on guild: Guild, client: any Sink) {}

    func on(deleteRole role: Role, from guild: Guild, client: any Sink) {}

    func on(updateRole role: Role, on guild: Guild, client: any Sink) {}

    func on(receivePresenceUpdate presence: Presence, client: any Sink) {}

    func on(createInteraction interaction: Interaction, client: any Sink) {}

    func on(receiveReady data: [String: Any], client: any Sink) {}

    func on(receiveVoiceStateUpdate state: VoiceState, client: any Sink) {}

    func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, client: any Sink) {}

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, client: any Sink) {}
}
