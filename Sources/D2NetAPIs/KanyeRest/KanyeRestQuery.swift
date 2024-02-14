import Utils

public struct KanyeRestQuery {
    public init() {}

    public func perform() -> Promise<KanyeQuote, any Error> {
        Promise.catching { try HTTPRequest(host: "api.kanye.rest", path: "/") }
            .then { $0.fetchJSONAsync(as: KanyeQuote.self) }
    }
}
