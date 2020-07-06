import D2Utils
import D2NetAPIs
import SQLite

fileprivate let wyrQuestions = Table("wyr_questions")
fileprivate let firstChoice = Expression<String>("first_choice")
fileprivate let secondChoice = Expression<String>("second_choice")
fileprivate let explanation = Expression<String?>("explanation")

fileprivate let nhieStatements = Table("nhie_statements")
fileprivate let statement = Expression<String>("statement")

public class PartyGameDatabase {
    private let db: Connection

    public init() throws {
        db = try Connection("local/partyGames.sqlite3")
    }

    public func setupTables() throws {
        try db.transaction {
            try db.run(wyrQuestions.create(ifNotExists: true) {
                $0.column(firstChoice, primaryKey: true)
                $0.column(secondChoice, primaryKey: true)
                $0.column(explanation)
            })
            try db.run(nhieStatements.create(ifNotExists: true) {
                $0.column(statement, primaryKey: true)
            })
        }
    }

    public func prepare(sql: String) throws -> Statement {
        try db.prepare(sql)
    }

    public func rebuild() -> Promise<Void, Error> {
        sequence(promises: [rebuildWyrQuestions, rebuildNhieStatements]).void()
    }

    private func rebuildWyrQuestions() -> Promise<Void, Error> {
        queryWyrQuestions()
            .then { questions in
                Promise.catching {
                    try self.db.transaction {
                        for q in questions {
                            try self.db.run(wyrQuestions.insert(or: .ignore,
                                firstChoice <- q.firstChoice,
                                secondChoice <- q.secondChoice,
                                explanation <- q.explanation
                            ))
                        }
                    }
                }
            }
    }

    private func rebuildNhieStatements() -> Promise<Void, Error> {
        queryNhieStatements()
            .then { statements in
                Promise.catching {
                    try self.db.transaction {
                        for s in statements {
                            try self.db.run(nhieStatements.insert(or: .ignore,
                                statement <- s.statement
                            ))
                        }
                    }
                }
            }
    }

    private func queryWyrQuestions() -> Promise<[WouldYouRatherQuestion], Error> {
        sequence(promises: ["conversation-starters", "school", "dating"].map { category in {
            Promise { then in
                WouldYouRatherQuery(category: category).perform {
                    then($0)
                }
            }
        } }).map { $0.flatMap { $0 } }
    }

    private func queryNhieStatements() -> Promise<[NeverHaveIEverStatement], Error> {
        Promise { then in
            NeverHaveIEverQuery(maxPages: 40).perform {
                then($0)
            }
        }
    }
}
