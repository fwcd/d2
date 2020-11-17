import Utils

public struct TaylorRestQuery {
    public init() {}

    public func perform() -> Promise<TaylorQuote, Error> {
        Promise.catching { try HTTPRequest(host: "api.taylor.rest", path: "/") }
            .then { $0.fetchJSONAsync(as: TaylorQuote.self) }
    }
}
