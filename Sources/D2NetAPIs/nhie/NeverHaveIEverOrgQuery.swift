import Utils

public struct NeverHaveIEverOrgQuery {
    public init() {}

    public func perform() -> Promise<NeverHaveIEverStatement, Error> {
        Promise.catching { try HTTPRequest(scheme: "http", host: "neverhaveiever.org", path: "/") }
            .then { $0.fetchHTMLAsync() }
            .mapCatching {
                guard let stmt = try $0.getElementsByClass("statement").array().first(where: { try $0.attr("url") != "/?" }) else { throw NeverHaveIEverQueryError.noStatementFound }
                return NeverHaveIEverStatement(statement: try stmt.text())
            }
    }
}
