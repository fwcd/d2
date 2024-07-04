import Utils

/// A handler for events from the message backend.
public protocol Receiver {
    func on(connect connected: Bool, sink: any Sink) async

    func on(disconnectWithReason reason: String, sink: any Sink) async

    func on(createChannel channel: Channel, sink: any Sink) async

    func on(deleteChannel channel: Channel, sink: any Sink) async

    func on(updateChannel channel: Channel, sink: any Sink) async

    func on(createThread thread: Channel, sink: any Sink) async

    func on(deleteThread thread: Channel, sink: any Sink) async

    func on(updateThread thread: Channel, sink: any Sink) async

    func on(createGuild guild: Guild, sink: any Sink) async

    func on(deleteGuild guild: Guild, sink: any Sink) async

    func on(updateGuild guild: Guild, sink: any Sink) async

    func on(addGuildMember member: Guild.Member, sink: any Sink) async

    func on(removeGuildMember member: Guild.Member, sink: any Sink) async

    func on(updateGuildMember member: Guild.Member, sink: any Sink) async

    func on(updateMessage message: Message, sink: any Sink) async

    func on(createMessage message: Message, sink: any Sink) async

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, sink: any Sink) async

    func on(createRole role: Role, on guild: Guild, sink: any Sink) async

    func on(deleteRole role: Role, from guild: Guild, sink: any Sink) async

    func on(updateRole role: Role, on guild: Guild, sink: any Sink) async

    func on(receivePresenceUpdate presence: Presence, sink: any Sink) async

    func on(createInteraction interaction: Interaction, sink: any Sink) async

    func on(receiveReady data: [String: Any], sink: any Sink) async

    func on(receiveVoiceStateUpdate state: VoiceState, sink: any Sink) async

    func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, sink: any Sink) async

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, sink: any Sink) async
}

public extension Receiver {
    func on(connect connected: Bool, sink: any Sink) async {}

    func on(disconnectWithReason reason: String, sink: any Sink) async {}

    func on(createChannel channel: Channel, sink: any Sink) async {}

    func on(deleteChannel channel: Channel, sink: any Sink) async {}

    func on(updateChannel channel: Channel, sink: any Sink) async {}

    func on(createThread thread: Channel, sink: any Sink) async {}

    func on(deleteThread thread: Channel, sink: any Sink) async {}

    func on(updateThread thread: Channel, sink: any Sink) async {}

    func on(createGuild guild: Guild, sink: any Sink) async {}

    func on(deleteGuild guild: Guild, sink: any Sink) async {}

    func on(updateGuild guild: Guild, sink: any Sink) async {}

    func on(addGuildMember member: Guild.Member, sink: any Sink) async {}

    func on(removeGuildMember member: Guild.Member, sink: any Sink) async {}

    func on(updateGuildMember member: Guild.Member, sink: any Sink) async {}

    func on(updateMessage message: Message, sink: any Sink) async {}

    func on(createMessage message: Message, sink: any Sink) async {}

    func on(addReaction reaction: Emoji, to messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async {}

    func on(removeReaction reaction: Emoji, from messageId: MessageID, on channelId: ChannelID, by userId: UserID, sink: any Sink) async {}

    func on(removeAllReactionsFrom message: MessageID, on channelId: ChannelID, sink: any Sink) async {}

    func on(createRole role: Role, on guild: Guild, sink: any Sink) async {}

    func on(deleteRole role: Role, from guild: Guild, sink: any Sink) async {}

    func on(updateRole role: Role, on guild: Guild, sink: any Sink) async {}

    func on(receivePresenceUpdate presence: Presence, sink: any Sink) async {}

    func on(createInteraction interaction: Interaction, sink: any Sink) async {}

    func on(receiveReady data: [String: Any], sink: any Sink) async {}

    func on(receiveVoiceStateUpdate state: VoiceState, sink: any Sink) async {}

    func on(handleGuildMemberChunk chunk: [UserID: Guild.Member], for guild: Guild, sink: any Sink) async {}

    func on(updateEmojis emojis: [EmojiID: Emoji], on guild: Guild, sink: any Sink) async {}
}
