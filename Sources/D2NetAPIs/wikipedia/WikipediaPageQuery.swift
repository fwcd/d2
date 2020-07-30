import D2Utils

public struct WikipediaPageQuery {
    private let page: String

    public init(pageName: String) {
        page = pageName
            .withFirstUppercased
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: " ", with: "_")
    }

    public func perform() -> Promise<WikipediaPage, Error> {
        Promise.catching { try HTTPRequest(
            host: "en.wikipedia.org",
            path: "/api/rest_v1/page/summary/\(page)"
        ) }
            .then { $0.fetchJSONAsync(as: WikipediaPage.self) }
    }
}
