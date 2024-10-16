import Utils
import D2NetAPIs
@preconcurrency import SQLite

fileprivate let wyrQuestions = Table("wyr_questions")
fileprivate let title = Expression<String>("title")
fileprivate let firstChoice = Expression<String>("first_choice")
fileprivate let secondChoice = Expression<String>("second_choice")
fileprivate let explanation = Expression<String?>("explanation")

fileprivate let nhieStatements = Table("nhie_statements")
fileprivate let statement = Expression<String>("statement")
fileprivate let category = Expression<String?>("category")

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
                $0.column(category)
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

    public func randomNhieStatement(category categoryToFilter: String? = nil) throws -> NeverHaveIEverStatement {
        var query = nhieStatements
        if let categoryToFilter {
            query = query.where(category == categoryToFilter)
        }
        guard let row = try db.prepare(query.order(Expression<Int>.random()).limit(1)).makeIterator().next() else {
            throw PartyGameDatabaseError.noSuchRow("No nhie statements in the database!")
        }

        return NeverHaveIEverStatement(
            statement: row[statement],
            category: row[category]
        )
    }

    public func rebuild() async throws {
        try await rebuildWyrQuestions()
        try await rebuildNhieStatements()
    }

    private func rebuildWyrQuestions() async throws {
        let questions = try await fetchWyrQuestions()
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

    private func rebuildNhieStatements() async throws {
        let statements = try await fetchNhieStatements()
        try self.db.transaction {
            for s in statements {
                try self.db.run(nhieStatements.insert(or: .ignore,
                    statement <- s.statement,
                    category <- s.category
                ))
            }
        }
    }

    private func fetchWyrQuestions() async throws -> [WouldYouRatherQuestion] {
        // TODO: We have disabled either.io here because the server seems to be down
        return try await fetchRRRatherQuestions()
    }

    private func fetchEitherIOQuestions() async throws -> [WouldYouRatherQuestion] {
        var questions: [WouldYouRatherQuestion] = []
        for c in "abcdefghijklmnopqrstuvwxyz" {
            questions += try await EitherIOQuery(term: String(c), maxOffset: 1500).perform()
        }
        return questions
    }

    private func fetchRRRatherQuestions() async throws -> [WouldYouRatherQuestion] {
        var questions: [WouldYouRatherQuestion] = []
        for category in ["conversation-starters", "school", "dating"] {
            questions += try await RRRatherQuery(category: category).perform()
        }
        return questions
    }

    private func fetchNhieStatements() async throws -> [NeverHaveIEverStatement] {
        return try await NNNEverQuery(maxPages: 40).perform() + RandomWordGeneratorNhieQuery().perform()
    }
}
