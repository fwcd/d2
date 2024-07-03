import XMLCoder
import Utils

public struct DBLPPublicationsQuery {
    public let term: String

    public init(term: String) {
        self.term = term
    }

    public func perform() async throws -> DBLPPublicationsResult {
        let request = try HTTPRequest(host: "dblp.org", path: "/search/publ/api", query: ["q": term])
        let data = try await request.run()
        return try XMLDecoder().decode(DBLPPublicationsResult.self, from: data)
    }
}
