import D2Utils
import SQLite

fileprivate let wyrQuestions = Table("wyr_questions")
fileprivate let question = Expression<String>("question")
fileprivate let firstChoice = Expression<String>("first_choice")
fileprivate let secondChoice = Expression<String>("second_choice")

fileprivate let nhieQuestions = Table("nhie_questions")

public class PartyGameDatabase {
    private let db: Connection

    public init() throws {
        db = try Connection("local/partyGames.sqlite3")
    }

    public func setupTables() throws {
        try db.transaction {
            try db.run(wyrQuestions.create(ifNotExists: true) {
                $0.column(question, primaryKey: true)
                $0.column(firstChoice)
                $0.column(secondChoice)
            })
            try db.run(nhieQuestions.create(ifNotExists: true) {
                $0.column(question, primaryKey: true)
            })
        }
    }

    public func prepare(sql: String) throws -> Statement {
        try db.prepare(sql)
    }

    public func rebuild() -> Promise<Void, Error> {
        // TODO
        Promise(())
    }
}
