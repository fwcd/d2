import D2Utils
import D2NetAPIs
import SQLite

fileprivate let wyrQuestions = Table("wyr_questions")
fileprivate let title = Expression<String>("title")
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
                $0.column(title)
                $0.column(firstChoice)
                $0.column(secondChoice)
                $0.column(explanation)
                $0.primaryKey(title, firstChoice, secondChoice)
            })
            try db.run(nhieStatements.create(ifNotExists: true) {
                $0.column(statement, primaryKey: true)
            })
        }
    }

    public func prepare(_ sql: String) throws -> Statement {
        try db.prepare(sql)
    }

    public func randomWyrQuestion() throws -> WouldYouRatherQuestion {
        guard let row = try db.prepare(wyrQuestions.order(Expression<Int>.random()).limit(1)).makeIterator().next() else {
            throw PartyGameDatabaseError.noSuchRow("No wyr questions in the database!")
        }

        return WouldYouRatherQuestion(
            title: row[title],
            firstChoice: row[firstChoice],
            secondChoice: row[secondChoice],
            explanation: row[explanation]
        )
    }

    public func randomNhieStatement() throws -> NeverHaveIEverStatement {
        guard let row = try db.prepare(nhieStatements.order(Expression<Int>.random()).limit(1)).makeIterator().next() else {
            throw PartyGameDatabaseError.noSuchRow("No nhie statements in the database!")
        }

        return NeverHaveIEverStatement(
            statement: row[statement]
        )
    }

    public func rebuild() -> Promise<Void, Error> {
        sequence(promises: [rebuildWyrQuestions, rebuildNhieStatements]).void()
    }

    private func rebuildWyrQuestions() -> Promise<Void, Error> {
        fetchWyrQuestions()
            .then { questions in
                Promise.catching {
                    try self.db.transaction {
                        for q in questions {
                            try self.db.run(wyrQuestions.insert(or: .ignore,
                                title <- q.title,
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
        fetchNhieStatements()
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

    private func fetchWyrQuestions() -> Promise<[WouldYouRatherQuestion], Error> {
        sequence(promises: ["conversation-starters", "school", "dating"].map { category in {
            Promise { then in
                RRRatherQuery(category: category).perform {
                    then($0)
                }
            }
        } }).map { $0.flatMap { $0 } }
    }

    private func fetchNhieStatements() -> Promise<[NeverHaveIEverStatement], Error> {
        Promise { then in
            NNNEverQuery(maxPages: 40).perform {
                then($0)
            }
        }
    }
}
