import XMLCoder
import D2Utils

public struct DBLPQuery {
    public let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform(then: @escaping (Result<DBLPResult, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "dblp.org", path: "/search/publ/api", query: ["q": term])
            request.runAsync {
                then($0.flatMap { r in Result { try XMLDecoder().decode(DBLPResult.self, from: r) } })
            }
        } catch {
            then(.failure(error))
        }
    }
}
