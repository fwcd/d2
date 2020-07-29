import XMLCoder
import D2Utils

public struct DBLPPublicationsQuery {
    public let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform() -> Promise<DBLPPublicationsResult, Error> {
        do {
            let request = try HTTPRequest(host: "dblp.org", path: "/search/publ/api", query: ["q": term])
            request.runAsync {
                then($0.flatMap { r in Result { try XMLDecoder().decode(DBLPPublicationsResult.self, from: r) } })
            }
        } catch {
            then(.failure(error))
        }
    }
}
