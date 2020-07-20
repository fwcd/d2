import SwiftSoup
import D2Utils

public struct NNNEverQuery {
    private let maxPages: Int

    public init(maxPages: Int) {
        self.maxPages = maxPages
    }

    public func perform(page: Int? = nil, prepending: [NeverHaveIEverStatement] = [], then: @escaping (Result<[NeverHaveIEverStatement], Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "nnnever.com", path: "/\(page.map { "\($0)" } ?? "")")
            request.fetchHTMLAsync { result in
                do {
                    let document = try result.get()
                    let rawStatements = try document.select(".question .title").array()
                    let statements = try rawStatements.map { NeverHaveIEverStatement(statement: try $0.text()) }

                    let nextPage = (page ?? 0) + 1
                    let nextLinks = try document.select(".pagination .page-link:contains(Next)")

                    if nextPage < self.maxPages && !nextLinks.isEmpty() {
                        self.perform(page: nextPage, prepending: prepending + statements, then: then)
                    } else {
                        then(.success(prepending + statements))
                    }
                } catch {
                    then(.failure(error))
                }
            }
        } catch {
            then(.failure(error))
        }
    }
}
