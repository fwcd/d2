import XMLCoder
import Utils

public struct DBLPPublicationsQuery {
    public let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform() async throws -> DBLPPublicationsResult {
        let request = try HTTPRequest(host: "dblp.org", path: "/search/publ/api", query: ["q": term])
        return try await request.fetchXML(as: DBLPPublicationsResult.self)
    }
}
