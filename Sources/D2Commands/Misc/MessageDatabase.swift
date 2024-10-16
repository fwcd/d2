import Foundation
import Logging
@preconcurrency import SQLite
import D2MessageIO
import Utils

fileprivate typealias Expression = SQLite.Expression

fileprivate let guilds = Table("guilds")
fileprivate let guildId = Expression<Int64>("guild_id")
fileprivate let guildName = Expression<String>("guild_name")
fileprivate let guildTracked = Expression<Bool>("guild_tracked")

fileprivate let channels = Table("channels")
fileprivate let channelName = Expression<String>("channel_name")

fileprivate let users = Table("users")
fileprivate let userId = Expression<Int64>("user_id")
fileprivate let userName = Expression<String>("user_name")
fileprivate let discriminator = Expression<String>("discriminator")
fileprivate let bot = Expression<Bool>("bot")
fileprivate let verified = Expression<Bool>("verified")

fileprivate let members = Table("members")
fileprivate let nick = Expression<String?>("nick")

fileprivate let memberRoles = Table("member_roles")

fileprivate let roles = Table("roles")
fileprivate let roleId = Expression<Int64>("role_id")
fileprivate let roleName = Expression<String>("role_name")
fileprivate let roleColor = Expression<Int64>("role_color")
fileprivate let rolePosition = Expression<Int64>("role_position")

fileprivate let messages = Table("messages")
fileprivate let messageId = Expression<Int64>("message_id")
fileprivate let authorId = Expression<Int64>("author_id")
fileprivate let channelId = Expression<Int64>("channel_id")
fileprivate let content = Expression<String>("content")
fileprivate let timestamp = Expression<Date>("timestamp")
fileprivate let hasAttachments = Expression<Bool>("has_attachments")
fileprivate let hasEmbed = Expression<Bool>("has_embed")
fileprivate let mentionsEveryone = Expression<Bool>("mentions_everyone")

fileprivate let reactions = Table("reactions")

fileprivate let userMentions = Table("user_mentions")

fileprivate let roleMentions = Table("role_mentions")

fileprivate let emojis = Table("emojis")
fileprivate let emojiId = Expression<Int64>("emoji_id")
fileprivate let emojiName = Expression<String>("emoji_name")
fileprivate let isAnimated = Expression<Bool>("is_animated")
fileprivate let isManaged = Expression<Bool>("is_managed")
fileprivate let requiresColons = Expression<Bool>("requires_colons")

fileprivate let emojiRoles = Table("emoji_roles")

fileprivate let markovTransitions = Table("markov_transitions")
fileprivate let word = Expression<String>("word")
fileprivate let followingWord = Expression<String>("following_word")
fileprivate let occurrences = Expression<Int64>("occurrences")

fileprivate let log = Logger(label: "D2Commands.MessageDatabase")

public final class MessageDatabase: MarkovPredictor, Sendable {
    private let db: Connection

    public private(set) lazy var initialMarkovDistribution: CustomDiscreteDistribution<String>? = queryInitialMarkovDistribution()
    public let markovOrder = 1

    public init() throws {
        db = try Connection("local/messages.sqlite3")
    }

    public func setupTables(sink: any Sink) throws {
        try db.transaction {
            try db.run(guilds.create(ifNotExists: true) {
                $0.column(guildId, primaryKey: true)
                $0.column(guildName)
                $0.column(guildTracked)
            })
            try db.run(channels.create(ifNotExists: true) {
                $0.column(channelId, primaryKey: true)
                $0.column(guildId, references: guilds, guildId)
                $0.column(channelName)
            })
            try db.run(users.create(ifNotExists: true) {
                $0.column(userId, primaryKey: true)
                $0.column(userName)
                $0.column(discriminator)
                $0.column(bot)
                $0.column(verified)
            })
            try db.run(members.create(ifNotExists: true) {
                $0.column(userId, references: users, userId)
                $0.column(guildId, references: guilds, guildId)
                $0.column(nick)
                $0.primaryKey(userId, guildId)
            })
            try db.run(memberRoles.create(ifNotExists: true) {
                $0.column(userId, references: users, userId)
                $0.column(guildId, references: guilds, guildId)
                $0.column(roleId, references: roles, roleId)
                $0.primaryKey(userId, guildId, roleId)
            })
            try db.run(roles.create(ifNotExists: true) {
                $0.column(roleId, primaryKey: true)
                $0.column(guildId, references: guilds, guildId)
                $0.column(roleName)
                $0.column(roleColor)
                $0.column(rolePosition)
            })
            try db.run(messages.create(ifNotExists: true) {
                $0.column(messageId, primaryKey: true)
                $0.column(authorId) // TODO: references user table?
                $0.column(channelId, references: channels, channelId)
                $0.column(content)
                $0.column(timestamp)
                $0.column(hasAttachments)
                $0.column(hasEmbed)
                $0.column(mentionsEveryone)
            })
            try db.run(reactions.create(ifNotExists: true) {
                $0.column(messageId)
                $0.column(emojiName)
                $0.column(userId)
                $0.primaryKey(messageId, emojiName, userId)
            })
            try db.run(userMentions.create(ifNotExists: true) {
                $0.column(messageId, references: messages, messageId)
                $0.column(userId, references: users, userId)
                $0.primaryKey(messageId, userId)
            })
            try db.run(roleMentions.create(ifNotExists: true) {
                $0.column(messageId, references: messages, messageId)
                $0.column(roleId, references: roles, roleId)
                $0.primaryKey(messageId, roleId)
            })
            try db.run(emojis.create(ifNotExists: true) {
                $0.column(emojiId, primaryKey: true)
                $0.column(emojiName)
                $0.column(isAnimated)
                $0.column(isManaged)
                $0.column(requiresColons)
            })
            try db.run(emojiRoles.create(ifNotExists: true) {
                $0.column(emojiId, references: emojis, emojiId)
                $0.column(roleId, references: roles, roleId)
                $0.primaryKey(emojiId, roleId)
            })
            try db.run(markovTransitions.create(ifNotExists: true) {
                $0.column(word)
                $0.column(followingWord)
                $0.column(occurrences)
                $0.primaryKey(word, followingWord)
            })
        }
    }

    public func prepare(_ sql: String, _ values: String...) throws -> Statement {
        try db.prepare(sql, values)
    }

    @discardableResult
    private func insertMessages(with sink: any Sink, from id: ChannelID, selection: MessageSelection? = nil) async throws -> MessageID? {
        let messages = try await sink.getMessages(for: id, limit: sink.messageFetchLimit ?? 20, selection: selection)
        guard !messages.isEmpty else { return nil }

        try self.db.transaction {
            for message in messages {
                try insertDirectly(message: message)
            }
        }

        if let msgId = messages.filter({ $0.id != nil }).min(by: ascendingComparator { $0.timestamp ?? Date.distantFuture })?.id {
            log.info("Fetching messages before \(msgId)")
            return try await insertMessages(with: sink, from: id, selection: .before(msgId))
        } else {
            return nil
        }
    }

    public func rebuildMessages(with sink: any Sink, from id: GuildID, debugMode: Bool = false, progressListener: ((String) async -> Void)? = nil) async throws {
        guard let guild = await sink.guild(for: id) else { throw MessageDatabaseError.invalidID("\(id)") }

        log.notice("Rebuilding messages in database...")
        try db.run(messages.delete())

        let guildChannels = debugMode ? guild.channels.prefix(10).compactMap { $0 } : Array(guild.channels)

        try await withThrowingDiscardingTaskGroup { group in
            for ch in guildChannels {
                if try await sink.isGuildTextChannel(ch.key) {
                    log.info("Fetching messages from channel \(ch.value.name)")
                    await progressListener?(ch.value.name)
                    try await self.insertMessages(with: sink, from: ch.key)
                }
            }
        }
    }

    public func isTracked(channelId id: ChannelID) throws -> Bool {
        let stmt = try db.prepare(guilds
            .select(guildTracked)
            .join(channels, on: channels[guildId] == guilds[guildId])
            .filter(channelId == convert(id: id)))
        return stmt.contains(where: { $0[guildTracked] })
    }

    public func isTracked(guildId id: GuildID) throws -> Bool {
        let stmt = try db.prepare(guilds
            .select(guildTracked)
            .filter(guildId == convert(id: id)))
        return stmt.contains(where: { $0[guildTracked] })
    }

    public func setTracked(_ tracked: Bool, guildId id: GuildID) throws {
        try db.run(guilds.filter(guildId == convert(id: id)).update(guildTracked <- tracked))
    }

    public func emojiIds(for name: String) throws -> [EmojiID] {
        let rows = try db.prepare(emojis.select(emojiId).where(emojiName == name))
        return rows.map { convertBack(id: $0[emojiId]) }
    }

    public func countReactions(authorId id: UserID, emojiName name: String) throws -> Int {
        let rows = try db.prepare(messages
            .select(emojiName.count)
            .join(reactions, on: messages[messageId] == reactions[messageId])
            .where(authorId == convert(id: id) && emojiName == name))
        return rows.makeIterator().next()![emojiName.count]
    }

    public func countReactions(reactorId id: UserID, emojiName name: String) throws -> Int {
        let rows = try db.prepare(reactions
            .select(emojiName.count)
            .where(userId == convert(id: id) && emojiName == name))
        return rows.makeIterator().next()![emojiName.count]
    }

    public func insert(guild: Guild) throws {
        let wasTracked = (try? isTracked(guildId: guild.id)) ?? false
        try db.transaction {
            try insertDirectly(guild: guild, tracked: wasTracked)
        }
    }

    private func insertDirectly(guild: Guild, tracked: Bool) throws {
        try db.run(guilds.insert(or: .replace,
            guildId <- try convert(id: guild.id),
            guildName <- guild.name,
            guildTracked <- tracked
        ))
        for member in guild.members.map(\.1) {
            try insertDirectly(member: member, on: guild)
        }
        for role in guild.roles.values {
            try insertDirectly(role: role, on: guild)
        }
        for channel in guild.channels.values {
            try insertDirectly(channel: channel, on: guild)
        }
        for emoji in guild.emojis.values {
            try insertDirectly(emoji: emoji)
        }
    }

    public func insert(member: Guild.Member, on guild: Guild) throws {
        try db.transaction {
            try insertDirectly(member: member, on: guild)
        }
    }

    private func insertDirectly(member: Guild.Member, on guild: Guild) throws {
        let user = member.user
        let id = user.id
        try db.run(members.insert(or: .replace,
            userId <- try convert(id: id),
            guildId <- try convert(id: guild.id),
            nick <- member.nick
        ))
        try db.run(users.insert(or: .replace,
            userId <- try convert(id: id),
            userName <- user.username,
            discriminator <- user.discriminator,
            bot <- user.bot,
            verified <- user.verified
        ))
        for rid in member.roleIds {
            try db.run(memberRoles.insert(or: .replace,
                userId <- try convert(id: id),
                guildId <- try convert(id: guild.id),
                roleId <- try convert(id: rid)
            ))
        }
    }

    public func insert(role: Role, on guild: Guild) throws {
        try db.transaction {
            try insertDirectly(role: role, on: guild)
        }
    }

    private func insertDirectly(role: Role, on guild: Guild) throws {
        let id = role.id
        try db.run(roles.insert(or: .replace,
            roleId <- try convert(id: id),
            guildId <- try convert(id: guild.id),
            roleName <- role.name,
            roleColor <- Int64(role.color),
            rolePosition <- Int64(role.position)
        ))
    }

    public func insert(channel: Channel, on guild: Guild) throws {
        try db.transaction {
            try insertDirectly(channel: channel, on: guild)
        }
    }

    private func insertDirectly(channel: Channel, on guild: Guild) throws {
        let id = channel.id
        try db.run(channels.insert(or: .replace,
            channelId <- try convert(id: id),
            guildId <- try convert(id: guild.id),
            channelName <- channel.name
        ))
    }

    public func insert(emoji: Emoji) throws {
        try db.transaction {
            try insertDirectly(emoji: emoji)
        }
    }

    private func insertDirectly(emoji: Emoji) throws {
        guard let id = emoji.id else { throw MessageDatabaseError.missingID("Emoji has no ID") }
        try db.run(emojis.insert(or: .replace,
            emojiId <- try convert(id: id),
            emojiName <- emoji.name,
            isAnimated <- emoji.animated,
            isManaged <- emoji.managed,
            requiresColons <- emoji.requireColons
        ))
        for rid in emoji.roles {
            try db.run(emojiRoles.insert(or: .replace,
                emojiId <- try convert(id: id),
                roleId <- try convert(id: rid)
            ))
        }
    }

    public func add(reaction emoji: Emoji, to id: MessageID, by uid: UserID) throws {
        try db.transaction {
            try db.run(reactions.insert(or: .ignore, messageId <- convert(id: id), emojiName <- emoji.name, userId <- convert(id: uid)))
        }
    }

    public func remove(reaction emoji: Emoji, from id: MessageID, by uid: UserID) throws {
        try db.transaction {
            try db.run(reactions.filter(messageId == convert(id: id) && emojiName == emoji.name && userId == convert(id: uid)).delete())
        }
    }

    public func remove(allReactionsFrom id: MessageID) throws {
        try db.transaction {
            try db.run(reactions.filter(messageId == convert(id: id)).delete())
        }
    }

    public func insert(message: Message) throws {
        try db.transaction {
            try insertDirectly(message: message)
        }
    }

    private func insertDirectly(message: Message) throws {
        guard let messageMessageId = try message.id.map(convert(id:)) else { throw MessageDatabaseError.missingID("Missing message ID") }
        guard let messageChannelId = try message.channelId.map(convert(id:)) else { throw MessageDatabaseError.missingID("Missing channel ID in message") }
        guard let messageAuthorId = try (message.author?.id).map(convert(id:)) else { throw MessageDatabaseError.missingID("Missing author ID in message") }
        guard let messageTimestamp = message.timestamp else { throw MessageDatabaseError.missingTimestamp }

        try db.run(messages.insert(or: .ignore,
            messageId <- messageMessageId,
            channelId <- messageChannelId,
            authorId <- messageAuthorId,
            content <- message.content,
            timestamp <- messageTimestamp,
            hasAttachments <- (message.attachments.count > 0),
            hasEmbed <- (message.embeds.count > 0),
            mentionsEveryone <- message.mentionEveryone
        ))
        for reaction in message.reactions {
            // TODO: The following loop will currently never run since
            //       users are not provided in the Discord API's representation
            //       of messages (they would have to be queried over a
            //       separate getReactions endpoint for each message individually)
            for user in reaction.users ?? [] {
                try db.run(reactions.insert(or: .ignore,
                    messageId <- messageMessageId,
                    emojiName <- reaction.emoji.name,
                    userId <- convert(id: user)
                ))
            }
        }
        for roleMention in message.mentionRoles {
            try db.run(roleMentions.insert(or: .ignore,
                messageId <- messageMessageId,
                roleId <- try convert(id: roleMention)
            ))
        }
        for mention in message.mentions {
            try db.run(userMentions.insert(or: .ignore,
                messageId <- messageMessageId,
                userId <- try convert(id: mention.id)
            ))
        }
    }

    private func convert(id: ID) throws -> Int64 {
        guard let idValue = Int64(id.value) else {
            throw MessageDatabaseError.invalidID("ID \(id.value) cannot be represented as a 64-bit unsigned int!")
        }
        return idValue
    }

    private func convertBack(id: Int64) -> ID {
        ID(String(id), clientName: "Unknown")
    }

    private func convertBack(emoji row: Row) -> Emoji {
        Emoji(
            id: convertBack(id: row[emojiId]),
            managed: row[isManaged],
            animated: row[isAnimated],
            name: row[emojiName],
            requireColons: row[requiresColons]
        )
    }

    @discardableResult
    public func generateMarkovTransitions(for message: Message) throws -> Int {
        try generateMarkovTransitions(text: message.content)
    }

    @discardableResult
    public func generateMarkovTransitions(text: String? = nil) throws -> Int {
        var count = 0

        if let text {
            let words = text.split(separator: " ").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if words.count > markovOrder {
                for i in 0..<(words.count - markovOrder) {
                    try db.run(markovTransitions.insert(
                        or: .ignore,
                        word <- words[i],
                        followingWord <- words[i + markovOrder],
                        occurrences <- 0
                    ))
                    try db.run(markovTransitions
                        .filter(word == words[i])
                        .update(occurrences++))
                    count += 1
                }
            }
        } else {
            let msgCount = try db.scalar(messages.count)
            let chunkSize = msgCount / 10

            // We assume that all messages fit into memory
            let contents = Array(try db.prepare(messages.select(messageId, content)).enumerated())

            try db.transaction {
                for (i, msg) in contents {
                    count += try generateMarkovTransitions(text: msg[content])

                    if i % chunkSize == 0 {
                        let progress = Double(i) / Double(msgCount)
                        log.info("Markov transitions \(String(format: "%.2f", progress * 100))% complete...")
                    }
                }
            }
        }

        return count
    }

    public func randomMessage() throws -> Message {
        guard let row = try db.prepare(messages.order(Expression<Int>.random()).limit(1)).makeIterator().next() else {
            throw MessageDatabaseError.missingMessageData("No message data available to sample from")
        }
        // TODO: Author info, etc
        // TODO: Timestamp deserialization doesn't work properly yet
        return Message(
            content: row[content],
            id: convertBack(id: row[messageId])
        )
    }

    public func randomMarkovWord() throws -> String {
        guard let row = try db.prepare(markovTransitions.select(word).order(Expression<Int>.random()).limit(1)).makeIterator().next() else {
            throw MessageDatabaseError.missingMarkovData("No Markov data available to sample from")
        }
        return row[word]
    }

    public func queryInitialMarkovDistribution() -> (CustomDiscreteDistribution<String>)? {
        do {
            let results = try db.prepare(markovTransitions.select(word, occurrences).order(occurrences.desc).limit(300))
                .map { ($0[word], $0[occurrences]) }
            log.info("Created initial distribution of size \(results.count)")
            guard !results.isEmpty else { return nil }
            return CustomDiscreteDistribution(normalizing: results)
        } catch {
            log.error("\(error)")
            return nil
        }
    }

    public func followUps(to suffix: String, on guildId: GuildID) throws -> [(String, String)] {
        // TODO: Use a typed query once they support subqueries properly

        // let m1 = messages.alias("m1")
        // let m2 = messages.alias("m2")
        // let one: Expression<Int> = .init(literal: "1")
        // let query = m1
        //     .join(m2, on: one == one) // Hack to get a pure cross product
        //     .filter(m1[content].like("%\(suffix)") && messages.select(timestamp.min).filter(timestamp > m1[timestamp] && m2[timestamp] == timestamp).exists)
        //     .order(Expression<Int>.random())
        //     .limit(10)

        let stmt = try db.prepare("""
            select m1.content, m2.content
            from messages as m1 natural join guilds as g1, messages as m2
            where m1.content like ?
            and m2.timestamp == (select min(timestamp) from messages where timestamp > m1.timestamp)
            and g1.guild_id == ?
            and m1.channel_id == m2.channel_id
            order by random()
            limit 10
            """, "%\(suffix)", "\(guildId)")

        return stmt.compactMap { row in (row[0] as? String).flatMap { l in (row[1] as? String).map { r in (l, r) } } }
    }

    public func predict(_ markovState: [String]) -> String? {
        do {
            guard markovState.count == 1, let stateWord = markovState.first else {
                throw MessageDatabaseError.invalidMarkovState("State \(markovState) has invalid length \(markovState.count)!")
            }
            let followerQuery = markovTransitions.select(followingWord, occurrences)
                .where(word == stateWord)
                .limit(50)
            let candidates = try db.prepare(followerQuery).map { ($0[followingWord], $0[occurrences]) }
            return candidates.nilIfEmpty.flatMap {
                CustomDiscreteDistribution(normalizing: $0)?.sample()
            }
        } catch {
            log.warning("\(error)")
            return nil
        }
    }

    public func queryMessagesPerMemberInChannels(on id: GuildID) throws -> [(channelName: String, userName: String, count: Int)] {
        let rows = try db.prepare(messages
            .join(users, on: userId == authorId)
            .join(channels, on: messages[channelId] == channels[channelId])
            .select(channelName, userName, content.count)
            .filter(guildId == convert(id: id))
            .group(messages[channelId], userId))
        return rows
            .map { (channelName: $0[channelName], userName: $0[userName], count: $0[content.count]) }
    }

    public func queryMostUsedEmojis(on id: GuildID, limit: Int? = nil, minTimestamp: Date? = nil) throws -> [(emoji: Emoji, count: Int)] {
        try Dictionary(grouping: [
            queryMostUsedEmojisInMessages(on: id, limit: limit, minTimestamp: minTimestamp),
            queryMostUsedEmojisInReactions(on: id, limit: limit, minTimestamp: minTimestamp)
        ].flatMap { $0 }, by: \.emoji)
            .map { (emoji: $0.key, count: $0.value.map(\.count).reduce(0, +)) }
    }

    public func queryMostUsedEmojisInMessages(on id: GuildID, limit: Int? = nil, minTimestamp: Date? = nil) throws -> [(emoji: Emoji, count: Int)] {
        let pattern: Expression<String> = "%<:" + emojiName + ":" + Expression<String>(emojiId) + ">%"
        var query = try emojis
            .join(messages, on: content.like(pattern))
            .join(channels, on: channels[channelId] == messages[channelId])
            .select(emojiName, emojiId, isAnimated, isManaged, requiresColons, content.count)
            .group(emojiName)
            .filter(guildId == convert(id: id))
            .order(content.count.desc)
        if let l = limit {
            query = query.limit(l)
        }
        if let m = minTimestamp {
            query = query.filter(timestamp >= m)
        }
        let rows = try db.prepare(query)
        return rows
            .map { (emoji: convertBack(emoji: $0), count: $0[content.count]) }
    }

    public func queryMostUsedEmojisInReactions(on id: GuildID, limit: Int? = nil, minTimestamp: Date? = nil) throws -> [(emoji: Emoji, count: Int)] {
        var query = try reactions
            .join(messages, on: messages[messageId] == reactions[messageId])
            .join(emojis, on: reactions[emojiName] == emojis[emojiName])
            .select(emojis[emojiName], emojiId, isAnimated, isManaged, requiresColons, content.count)
            .group(emojis[emojiName])
            .filter(guildId == convert(id: id))
            .order(content.count.desc)
        if let l = limit {
            query = query.limit(l)
        }
        if let m = minTimestamp {
            query = query.filter(timestamp >= m)
        }
        let rows = try db.prepare(query)
        return rows
            .map { (emoji: convertBack(emoji: $0), count: $0[content.count]) }
    }
}
