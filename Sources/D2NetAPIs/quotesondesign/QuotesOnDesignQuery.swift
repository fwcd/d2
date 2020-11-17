import Utils

public struct QuotesOnDesignQuery {
    public init() {}

    public func perform() -> Promise<[DesignQuote], Error> {
        Promise.catching { try HTTPRequest(host: "quotesondesign.com", path: "/wp-json/wp/v2/posts", query: ["orderby": "rand"]) }
            .then { $0.fetchJSONAsync(as: [DesignQuote].self) }
    }
}
