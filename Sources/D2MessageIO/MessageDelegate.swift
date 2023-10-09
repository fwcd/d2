import Utils

/// A handler for events from the message backend.
public protocol MessageDelegate {
    func on(connect connected: Bool, client: any MessageIOSink)

    func on(disconnectWithReason reason: String, client: any MessageIOSink)

    func on(createChannel channel: Channel, client: any MessageIOSink)

    func on(deleteChannel channel: Channel, client: any MessageIOSink)

    func on(updateChannel channel: Channel, client: any MessageIOSink)

    func on(createThread thread: Channel, client: any MessageIOSink)

    func on(deleteThread thread: Channel, client: any MessageIOSink)

    func on(updateThread thread: Channel, client: any MessageIOSink)

    func on(createGuild guild: Guild, client: any MessageIOSink)

    func on(deleteGuild guild: Guild, client: any MessageIOSink)

    func on(updateGuild guild: Guild, client: any MessageIOSink)

    func on(addGuildMember member: Guild.Member, client: any MessageIOSink)

    func on(removeGuildMember member: Guild.Member, client: any MessageIOSink)

    func on(updateGuildMember member: Guild.Member, client: any MessageIOSink)

    func on(updateMessage message: Message, client: any MessageIOSink)

    func on(createMessage message: Message, client: any MessageIOSink)

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageIOSink)

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageIOSink)

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, client: any MessageIOSink)

    func on(createRole role: Role, on guild: Guild, client: any MessageIOSink)

    func on(deleteRole role: Role, from guild: Guild, client: any MessageIOSink)

    func on(updateRole role: Role, on guild: Guild, client: any MessageIOSink)

    func on(receivePresenceUpdate presence: Presence, client: any MessageIOSink)

    func on(createInteraction interaction: Interaction, client: any MessageIOSink)

    func on(receiveReady data: [String: Any], client: any MessageIOSink)

    func on(receiveVoiceStateUpdate state: VoiceState, client: any MessageIOSink)

    func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, client: any MessageIOSink)

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, client: any MessageIOSink)
}

public extension MessageDelegate {
    func on(connect connected: Bool, client: any MessageIOSink) {}

    func on(disconnectWithReason reason: String, client: any MessageIOSink) {}

    func on(createChannel channel: Channel, client: any MessageIOSink) {}

    func on(deleteChannel channel: Channel, client: any MessageIOSink) {}

    func on(updateChannel channel: Channel, client: any MessageIOSink) {}

    func on(createThread thread: Channel, client: any MessageIOSink) {}

    func on(deleteThread thread: Channel, client: any MessageIOSink) {}

    func on(updateThread thread: Channel, client: any MessageIOSink) {}

    func on(createGuild guild: Guild, client: any MessageIOSink) {}

    func on(deleteGuild guild: Guild, client: any MessageIOSink) {}

    func on(updateGuild guild: Guild, client: any MessageIOSink) {}

    func on(addGuildMember member: Guild.Member, client: any MessageIOSink) {}

    func on(removeGuildMember member: Guild.Member, client: any MessageIOSink) {}

    func on(updateGuildMember member: Guild.Member, client: any MessageIOSink) {}

    func on(updateMessage message: Message, client: any MessageIOSink) {}

    func on(createMessage message: Message, client: any MessageIOSink) {}

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageIOSink) {}

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, client: any MessageIOSink) {}

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, client: any MessageIOSink) {}

    func on(createRole role: Role, on guild: Guild, client: any MessageIOSink) {}

    func on(deleteRole role: Role, from guild: Guild, client: any MessageIOSink) {}

    func on(updateRole role: Role, on guild: Guild, client: any MessageIOSink) {}

    func on(receivePresenceUpdate presence: Presence, client: any MessageIOSink) {}

    func on(createInteraction interaction: Interaction, client: any MessageIOSink) {}

    func on(receiveReady data: [String: Any], client: any MessageIOSink) {}

    func on(receiveVoiceStateUpdate state: VoiceState, client: any MessageIOSink) {}

    func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, client: any MessageIOSink) {}

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, client: any MessageIOSink) {}
}
