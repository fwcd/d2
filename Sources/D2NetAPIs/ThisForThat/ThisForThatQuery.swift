import Utils

public struct ThisForThatQuery {
    public init() {}

    public func perform() -> Promise<ThisForThat, any Error> {
        Promise.catching { try HTTPRequest(host: "itsthisforthat.com", path: "/api.php", query: ["json": ""]) }
            .then { $0.fetchJSONAsync(as: ThisForThat.self) }
    }
}
