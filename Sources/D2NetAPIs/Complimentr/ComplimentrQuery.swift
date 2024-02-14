import Utils

public struct ComplimentrQuery {
    public init() {}

    public func perform() -> Promise<Compliment, any Error> {
        Promise.catching { try HTTPRequest(host: "complimentr.com", path: "/api") }
            .then { $0.fetchJSONAsync(as: Compliment.self) }
    }
}
