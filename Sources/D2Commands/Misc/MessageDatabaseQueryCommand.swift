import Utils

// Source: https://www.sqlite.org/lang_select.html

// TODO: Recursive expressions are not supported, since Foundation's regex engine does not support those
// TODO: Migrate to regex builders
fileprivate let literalExpr = "[\\w\\d_-]+|\"[^\"]*\""
fileprivate let unaryExpr = "(?:\(literalExpr))(?:\\s+is(?:\\s+not)?(?:\\s+null|(?:\(literalExpr))))?"
fileprivate let binaryExpr = "(?:\(unaryExpr))(?:\\s+(?:==|<|<=|>|>=|<>|like)\\s+(?:\(unaryExpr)))?"
fileprivate let andExpr = "(?:\(binaryExpr))(?:\\s+and\\s+(?:\(binaryExpr)))*"
fileprivate let orExpr = "(?:\(andExpr))(?:\\s+and\\s+(?:\(andExpr)))*"
fileprivate let expr = orExpr
fileprivate let table = "\\w+"
fileprivate let columnAlias = "\\w+"
fileprivate let columnName = "\\w+"
fileprivate let alias = "\\s+(?:as\\s+)?(?:\(columnAlias))"
fileprivate let aggregation = "(?:count|avg|min|max)\\s*\\((?:\\*|\\w+)\\)"
fileprivate let resultColumn = "(?:(?:\(expr))|\\*|(?:\(aggregation)))(?:\(alias))?"
fileprivate let joinOperator = ",|(?:(?:natural)?\\s*(?:left\\s*(?:outer|inner|cross)?)?\\s*join)"
fileprivate let joinConstraint = "(?:on\\s+(?:\(expr))|using\\s+\\((?:\(columnName)(?:\\s*,\\s*(?:\(columnName)))*)\\))?" // TODO
fileprivate let joinClause = "\(table)\\s*(?:(?:\(joinOperator))\\s*(?:\(table))\\s*(?:\(joinConstraint))\\s*)*"
fileprivate let fromClause = "from\\s+(?:(?:\(joinClause))|(?:\(table))\\s*(?:,\\s*\(table)\\s*)*)"
fileprivate let whereClause = "where\\s+(?:\(expr))"
fileprivate let groupByClause = "group\\s+by\\s+(?:\(expr))(?:\\s*,\\s*(?:\(expr)))*"
fileprivate let havingClause = "having\\s+(?:\(expr))"
fileprivate let groupByHavingClause = "(?:\(groupByClause))\\s*(?:\(havingClause))?"
fileprivate let orderingTerm = "\(expr)\\s*(?:asc|desc)?\\s*(?:nulls\\s+(?:first|last))?"
fileprivate let orderByClause = "order\\s+by\\s+(?:\(orderingTerm))(?:\\s*,\\s*(?:\(orderingTerm)))*"
fileprivate let limitClause = "limit\\s+(\\d+)" // TODO: Fix issue that numbers are not parsed
fileprivate let selectModifier = "distinct|all"
fileprivate let clauses = [fromClause, whereClause, groupByHavingClause, orderByClause, limitClause].map { "(?:\($0))?" }.joined(separator: "\\s*")
fileprivate let rawSelectStmt = "^select(?:\\s*(?:\(selectModifier)))?\\s*(?:\(resultColumn))(?:,\\s*(?:\(resultColumn))\\s*)*\\s*(?:\(clauses))$"
fileprivate let selectStmtPattern = try! Regex(rawSelectStmt)

public class MessageDatabaseQueryCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Lets the user send safe SQL commands to the local database",
        requiredPermissionLevel: .vip
    )
    private let messageDB: MessageDatabase
    private let maxRows: Int

    public init(messageDB: MessageDatabase, maxRows: Int = 10) {
        self.messageDB = messageDB
        self.maxRows = maxRows
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        guard let parsed = try? selectStmtPattern.firstMatch(in: input.lowercased()) else {
            output.append(errorText: "Please enter a limiting SELECT statement! Note that currently not all SELECT statements are understood. If your query is valid SQL, please file a bug [here](https://github.com/fwcd/d2/issues).")
            return
        }

        guard parsed[0].substring?.count == input.count else {
            output.append(errorText: "Could not parse your entire query. Only recognized: `\(input)`")
            return
        }

        let limit = parsed[safely: 1]?.substring.flatMap { Int($0) } ?? Int.max
        guard limit < maxRows else {
            output.append(errorText: "Please query less than \(maxRows) rows!")
            return
        }

        do {
            let result = try messageDB.prepare(input)
                .map { "(\($0.map { $0.map { "\($0)" } ?? "nil" }.joined(separator: ", ")))".nilIfEmpty ?? "no results" }
                .joined(separator: "\n")
            output.append(.code(result, language: nil))
        } catch {
            output.append(error, errorText: "Could not perform query")
        }
    }
}
