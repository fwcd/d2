import Utils

public struct QuotesOnDesignQuery {
    public init() {}

    public func perform() async throws -> [DesignQuote] {
        let request = try HTTPRequest(host: "quotesondesign.com", path: "/wp-json/wp/v2/posts", query: ["orderby": "rand"])
        return try await request.fetchJSON(as: [DesignQuote].self)
    }
}
