import SQLite
import D2MessageIO

fileprivate let messages = Table("messages")
fileprivate let messageId = Expression<UInt64>("message_id")
fileprivate let content = Expression<String>("content")

fileprivate let markov = Table("markov")
fileprivate let wordA = Expression<String>("word_a")
fileprivate let wordB = Expression<String>("word_b")
fileprivate let wordC = Expression<String>("word_c")
fileprivate let followingWord = Expression<String>("following_word")
    
public class MessageDatabase {
    private let db: Connection
    
    public init() throws {
        db = try Connection("local/messages.sqlite3")
    }

    public func populate(with client: MessageClient, guildId: GuildID) throws {
        // TODO
    }
}
