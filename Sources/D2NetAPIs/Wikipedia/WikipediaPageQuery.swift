import Utils

public struct WikipediaPageQuery {
    private let page: String

    public init(pageName: String) {
        page = pageName
            .withFirstUppercased
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: " ", with: "_")
    }

    public func perform() async throws -> WikipediaPage {
        let request = try HTTPRequest(
            host: "en.wikipedia.org",
            path: "/api/rest_v1/page/summary/\(page)"
        )
        return try await request.fetchJSON(as: WikipediaPage.self)
    }
}
