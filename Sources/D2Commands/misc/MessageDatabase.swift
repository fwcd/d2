import Foundation
import Logging
import SQLite
import D2MessageIO
import D2Utils

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
    
public class MessageDatabase: MarkovPredictor {
    private let db: Connection

    public private(set) lazy var initialMarkovDistribution: CustomDiscreteDistribution<String>? = queryInitialMarkovDistribution()
    public let markovOrder = 1
    
    public init() throws {
        db = try Connection("local/messages.sqlite3")
    }
    
    public func setupTables(client: MessageClient) throws {
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
    
    public func prepare(sql: String) throws -> Statement {
        try db.prepare(sql)
    }

    private func insertMessages(with client: MessageClient, from id: ChannelID, selection: MessageSelection? = nil) -> Promise<MessageID?, Error> {
        Promise<MessageID?, Error> { then in
            client.getMessages(for: id, limit: client.messageFetchLimit ?? 20, selection: selection) { messages, _ in
                do {
                    if messages.isEmpty {
                        then(.success(nil))
                    } else {
                        try self.db.transaction {
                            for message in messages {
                                try self.insertDirectly(message: message)
                            }
                        }
                        then(.success(messages
                            .filter { $0.id != nil }
                            .min(by: ascendingComparator { $0.timestamp ?? Date.distantFuture })
                            .map { $0.id! }))
                    }
                } catch {
                    then(.failure(error))
                }
            }
        }.then {
            if let msgId = $0 {
                log.info("Fetching messages before \(msgId)")
                return self.insertMessages(with: client, from: id, selection: .before(msgId))
            } else {
                return Promise(.success(nil))
            }
        }
    }

    public func rebuildMessages(with client: MessageClient, from id: GuildID, debugMode: Bool = false, progressListener: ((String) -> Void)? = nil) -> Promise<Void, Error> {
        guard let guild = client.guild(for: id) else { return Promise(.failure(MessageDatabaseError.invalidID("\(id)"))) }

        do {
            log.notice("Rebuilding messages in database...")
            try db.run(messages.delete())

            let guildChannels = debugMode ? guild.channels.prefix(10).compactMap { $0 } : Array(guild.channels)
            let promises: [Promise<Void, Error>] = guildChannels.map { ch in
                Promise { then in
                    client.isGuildTextChannel(ch.key) { i, _ in
                        then(.success(i))
                    }
                }.then {
                    if $0 {
                        log.info("Fetching messages from channel \(ch.value.name)")
                        progressListener?(ch.value.name)
                        return self.insertMessages(with: client, from: ch.key).void()
                    } else {
                        return Promise(.success(()))
                    }
                } 
            }
            return all(promises: promises).void()
        } catch {
            return Promise(.failure(error))
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
        try db.transaction {
            try db.run(guilds.insert(or: .ignore,
                guildId <- try convert(id: guild.id),
                guildName <- guild.name,
                guildTracked <- false
            ))
            for (id, member) in guild.members {
                let user = member.user
                try db.run(members.insert(or: .ignore,
                    userId <- try convert(id: id),
                    guildId <- try convert(id: guild.id),
                    nick <- member.nick
                ))
                try db.run(users.insert(or: .ignore,
                    userId <- try convert(id: id),
                    userName <- user.username,
                    discriminator <- user.discriminator,
                    bot <- user.bot,
                    verified <- user.verified
                ))
                for rid in member.roleIds {
                    try db.run(memberRoles.insert(or: .ignore,
                        userId <- try convert(id: id),
                        guildId <- try convert(id: guild.id),
                        roleId <- try convert(id: rid)
                    ))
                }
            }
            for (id, role) in guild.roles {
                try db.run(roles.insert(or: .ignore,
                    roleId <- try convert(id: id),
                    guildId <- try convert(id: guild.id),
                    roleName <- role.name,
                    roleColor <- Int64(role.color),
                    rolePosition <- Int64(role.position)
                ))
            }
            for (id, channel) in guild.channels {
                try db.run(channels.insert(or: .ignore,
                    channelId <- try convert(id: id),
                    guildId <- try convert(id: guild.id),
                    channelName <- channel.name
                ))
            }
            for (id, emoji) in guild.emojis {
                try db.run(emojis.insert(or: .ignore,
                    emojiId <- try convert(id: id),
                    emojiName <- emoji.name,
                    isAnimated <- emoji.animated,
                    isManaged <- emoji.managed,
                    requiresColons <- emoji.requireColons
                ))
                for rid in emoji.roles {
                    try db.run(emojiRoles.insert(or: .ignore,
                        emojiId <- try convert(id: id),
                        roleId <- try convert(id: rid)
                    ))
                }
            }
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

    @discardableResult
    public func generateMarkovTransitions(for message: Message) throws -> Int {
        try generateMarkovTransitions(text: message.content)
    }
    
    @discardableResult
    public func generateMarkovTransitions(text: String? = nil) throws -> Int {
        var count = 0

        if let text = text {
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
}
