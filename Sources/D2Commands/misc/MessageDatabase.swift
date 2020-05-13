import Foundation
import Logging
import SQLite
import D2MessageIO
import D2Utils

fileprivate let guilds = Table("guilds")
fileprivate let guildId = Expression<Int64>("guild_id")
fileprivate let guildName = Expression<String>("guild_name")

fileprivate let channels = Table("channels")
fileprivate let channelName = Expression<String>("channel_name")

// TODO: Users table?

fileprivate let messages = Table("messages")
fileprivate let messageId = Expression<Int64>("message_id")
fileprivate let authorId = Expression<Int64>("author_id")
fileprivate let channelId = Expression<Int64>("channel_id")
fileprivate let content = Expression<String>("content")
fileprivate let timestamp = Expression<Date>("timestamp")
fileprivate let hasAttachments = Expression<Bool>("has_attachments")
fileprivate let hasEmbed = Expression<Bool>("has_embed")

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
            })
            try db.run(channels.create(ifNotExists: true) {
                $0.column(channelId, primaryKey: true)
                $0.column(guildId, references: guilds, guildId)
                $0.column(channelName)
            })
            try db.run(messages.create(ifNotExists: true) {
                $0.column(messageId, primaryKey: true)
                $0.column(authorId) // TODO: references user table?
                $0.column(channelId, references: channels, channelId)
                $0.column(content)
                $0.column(timestamp)
                $0.column(hasAttachments)
                $0.column(hasEmbed)
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

    public func queryMissingMessages(with client: MessageClient, from guildId: GuildID) throws {
        // TODO
    }

    public func insert(guild: Guild) throws {
        try db.run(guilds.insert(or: .ignore,
            guildId <- try convert(id: guild.id),
            guildName <- guild.name
        ))
        for (id, channel) in guild.channels {
            try db.run(channels.insert(or: .ignore,
                channelId <- try convert(id: id),
                guildId <- try convert(id: guild.id),
                channelName <- channel.name
            ))
        }
    }
    
    public func insert(message: Message) throws {
        guard let messageMessageId = message.id else { throw MessageDatabaseError.missingID("Missing message ID") }
        guard let messageChannelId = message.channelId else { throw MessageDatabaseError.missingID("Missing channel ID in message") }
        guard let messageAuthorId = message.author?.id else { throw MessageDatabaseError.missingID("Missing author ID in message") }
        guard let messageTimestamp = message.timestamp else { throw MessageDatabaseError.missingTimestamp }
        try db.run(messages.insert(
            messageId <- try convert(id: messageMessageId),
            channelId <- try convert(id: messageChannelId),
            authorId <- try convert(id: messageAuthorId),
            content <- message.content,
            timestamp <- messageTimestamp,
            hasAttachments <- (message.attachments.count > 0),
            hasEmbed <- (message.embeds.count > 0)
        ))
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
            return candidates.nilIfEmpty.map {
                CustomDiscreteDistribution(normalizing: $0).sample()
            }
        } catch {
            log.warning("\(error)")
            return nil
        }
    }
}
