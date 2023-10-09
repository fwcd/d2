import Utils

/// A handler for events from the message backend.
public protocol Receiver {
    func on(connect connected: Bool, sink: any Sink)

    func on(disconnectWithReason reason: String, sink: any Sink)

    func on(createChannel channel: Channel, sink: any Sink)

    func on(deleteChannel channel: Channel, sink: any Sink)

    func on(updateChannel channel: Channel, sink: any Sink)

    func on(createThread thread: Channel, sink: any Sink)

    func on(deleteThread thread: Channel, sink: any Sink)

    func on(updateThread thread: Channel, sink: any Sink)

    func on(createGuild guild: Guild, sink: any Sink)

    func on(deleteGuild guild: Guild, sink: any Sink)

    func on(updateGuild guild: Guild, sink: any Sink)

    func on(addGuildMember member: Guild.Member, sink: any Sink)

    func on(removeGuildMember member: Guild.Member, sink: any Sink)

    func on(updateGuildMember member: Guild.Member, sink: any Sink)

    func on(updateMessage message: Message, sink: any Sink)

    func on(createMessage message: Message, sink: any Sink)

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink)

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink)

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, sink: any Sink)

    func on(createRole role: Role, on guild: Guild, sink: any Sink)

    func on(deleteRole role: Role, from guild: Guild, sink: any Sink)

    func on(updateRole role: Role, on guild: Guild, sink: any Sink)

    func on(receivePresenceUpdate presence: Presence, sink: any Sink)

    func on(createInteraction interaction: Interaction, sink: any Sink)

    func on(receiveReady data: [String: Any], sink: any Sink)

    func on(receiveVoiceStateUpdate state: VoiceState, sink: any Sink)

    func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, sink: any Sink)

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, sink: any Sink)
}

public extension Receiver {
    func on(connect connected: Bool, sink: any Sink) {}

    func on(disconnectWithReason reason: String, sink: any Sink) {}

    func on(createChannel channel: Channel, sink: any Sink) {}

    func on(deleteChannel channel: Channel, sink: any Sink) {}

    func on(updateChannel channel: Channel, sink: any Sink) {}

    func on(createThread thread: Channel, sink: any Sink) {}

    func on(deleteThread thread: Channel, sink: any Sink) {}

    func on(updateThread thread: Channel, sink: any Sink) {}

    func on(createGuild guild: Guild, sink: any Sink) {}

    func on(deleteGuild guild: Guild, sink: any Sink) {}

    func on(updateGuild guild: Guild, sink: any Sink) {}

    func on(addGuildMember member: Guild.Member, sink: any Sink) {}

    func on(removeGuildMember member: Guild.Member, sink: any Sink) {}

    func on(updateGuildMember member: Guild.Member, sink: any Sink) {}

    func on(updateMessage message: Message, sink: any Sink) {}

    func on(createMessage message: Message, sink: any Sink) {}

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) {}

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) {}

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, sink: any Sink) {}

    func on(createRole role: Role, on guild: Guild, sink: any Sink) {}

    func on(deleteRole role: Role, from guild: Guild, sink: any Sink) {}

    func on(updateRole role: Role, on guild: Guild, sink: any Sink) {}

    func on(receivePresenceUpdate presence: Presence, sink: any Sink) {}

    func on(createInteraction interaction: Interaction, sink: any Sink) {}

    func on(receiveReady data: [String: Any], sink: any Sink) {}

    func on(receiveVoiceStateUpdate state: VoiceState, sink: any Sink) {}

    func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, sink: any Sink) {}

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, sink: any Sink) {}
}
