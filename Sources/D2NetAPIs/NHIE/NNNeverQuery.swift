@preconcurrency import SwiftSoup
import Utils

public struct NNNEverQuery {
    private let maxPages: Int

    public init(maxPages: Int) {
        self.maxPages = maxPages
    }

    public func perform(page: Int? = nil, prepending: [NeverHaveIEverStatement] = []) async throws -> [NeverHaveIEverStatement] {
        let request = try HTTPRequest(host: "nnnever.com", path: "/\(page.map { "\($0)" } ?? "")")
        let document = try await request.fetchHTML()
        let rawStatements = try document.select(".question .title").array()
        let statements = try rawStatements.map { NeverHaveIEverStatement(statement: try $0.text()) }

        let nextPage = (page ?? 0) + 1
        let nextLinks = try document.select(".pagination .page-link:contains(Next)")

        if nextPage < maxPages && !nextLinks.isEmpty() {
            return try await perform(page: nextPage, prepending: prepending + statements)
        } else {
            return prepending + statements
        }
    }
}
