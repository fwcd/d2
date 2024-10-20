import Utils

// Source: https://www.sqlite.org/lang_select.html

// TODO: Recursive expressions are not supported, since Foundation's regex engine does not support those
// TODO: Migrate to regex builders
private let literalExpr = "[\\w\\d_-]+|\"[^\"]*\""
private let unaryExpr = "(?:\(literalExpr))(?:\\s+is(?:\\s+not)?(?:\\s+null|(?:\(literalExpr))))?"
private let binaryExpr = "(?:\(unaryExpr))(?:\\s+(?:==|<|<=|>|>=|<>|like)\\s+(?:\(unaryExpr)))?"
private let andExpr = "(?:\(binaryExpr))(?:\\s+and\\s+(?:\(binaryExpr)))*"
private let orExpr = "(?:\(andExpr))(?:\\s+and\\s+(?:\(andExpr)))*"
private let expr = orExpr
private let table = "\\w+"
private let columnAlias = "\\w+"
private let columnName = "\\w+"
private let alias = "\\s+(?:as\\s+)?(?:\(columnAlias))"
private let aggregation = "(?:count|avg|min|max)\\s*\\((?:\\*|\\w+)\\)"
private let resultColumn = "(?:(?:\(expr))|\\*|(?:\(aggregation)))(?:\(alias))?"
private let joinOperator = ",|(?:(?:natural)?\\s*(?:left\\s*(?:outer|inner|cross)?)?\\s*join)"
private let joinConstraint = "(?:on\\s+(?:\(expr))|using\\s+\\((?:\(columnName)(?:\\s*,\\s*(?:\(columnName)))*)\\))?" // TODO
private let joinClause = "\(table)\\s*(?:(?:\(joinOperator))\\s*(?:\(table))\\s*(?:\(joinConstraint))\\s*)*"
private let fromClause = "from\\s+(?:(?:\(joinClause))|(?:\(table))\\s*(?:,\\s*\(table)\\s*)*)"
private let whereClause = "where\\s+(?:\(expr))"
private let groupByClause = "group\\s+by\\s+(?:\(expr))(?:\\s*,\\s*(?:\(expr)))*"
private let havingClause = "having\\s+(?:\(expr))"
private let groupByHavingClause = "(?:\(groupByClause))\\s*(?:\(havingClause))?"
private let orderingTerm = "\(expr)\\s*(?:asc|desc)?\\s*(?:nulls\\s+(?:first|last))?"
private let orderByClause = "order\\s+by\\s+(?:\(orderingTerm))(?:\\s*,\\s*(?:\(orderingTerm)))*"
private let limitClause = "limit\\s+(\\d+)" // TODO: Fix issue that numbers are not parsed
private let selectModifier = "distinct|all"
private let clauses = [fromClause, whereClause, groupByHavingClause, orderByClause, limitClause].map { "(?:\($0))?" }.joined(separator: "\\s*")
private let rawSelectStmt = "^select(?:\\s*(?:\(selectModifier)))?\\s*(?:\(resultColumn))(?:,\\s*(?:\(resultColumn))\\s*)*\\s*(?:\(clauses))$"
nonisolated(unsafe) private let selectStmtPattern = try! Regex(rawSelectStmt)

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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let parsed = try? selectStmtPattern.firstMatch(in: input.lowercased()) else {
            await output.append(errorText: "Please enter a limiting SELECT statement! Note that currently not all SELECT statements are understood. If your query is valid SQL, please file a bug [here](https://github.com/fwcd/d2/issues).")
            return
        }

        guard parsed[0].substring?.count == input.count else {
            await output.append(errorText: "Could not parse your entire query. Only recognized: `\(input)`")
            return
        }

        let limit = parsed[safely: 1]?.substring.flatMap { Int($0) } ?? Int.max
        guard limit < maxRows else {
            await output.append(errorText: "Please query less than \(maxRows) rows!")
            return
        }

        do {
            let result = try messageDB.prepare(input)
                .map { "(\($0.map { $0.map { "\($0)" } ?? "nil" }.joined(separator: ", ")))".nilIfEmpty ?? "no results" }
                .joined(separator: "\n")
            await output.append(.code(result, language: nil))
        } catch {
            await output.append(error, errorText: "Could not perform query")
        }
    }
}
