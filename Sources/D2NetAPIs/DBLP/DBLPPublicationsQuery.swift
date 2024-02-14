import XMLCoder
import Utils

public struct DBLPPublicationsQuery {
    public let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform() -> Promise<DBLPPublicationsResult, any Error> {
        Promise.catching { try HTTPRequest(host: "dblp.org", path: "/search/publ/api", query: ["q": term]) }
            .then { $0.runAsync() }
            .mapCatching { try XMLDecoder().decode(DBLPPublicationsResult.self, from: $0) }
    }
}
