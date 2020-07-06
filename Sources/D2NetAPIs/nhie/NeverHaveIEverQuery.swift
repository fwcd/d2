import SwiftSoup
import D2Utils

public struct NeverHaveIEverQuery {
    private let maxPages: Int

    public init(maxPages: Int) {
        self.maxPages = maxPages
    }

    public func perform(page: Int? = nil, then: @escaping (Result<[NeverHaveIEverStatement], Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "nnnever.com", path: "/\(page.map { "\($0)" } ?? "")")
            request.fetchHTMLAsync { result in
                then(Result {
                    let document = try result.get()
                    let rawStatements = try document.select(".question .title").array()
                    let statements = try rawStatements.map { NeverHaveIEverStatement(statement: try $0.text()) }

                    return statements
                })
            }
        } catch {
            then(.failure(error))
        }
    }
}
