import Utils

public struct NhieIoQuery {
    public init() {}

    public func perform() -> Promise<NeverHaveIEverStatement, Error> {
        Promise.catching { try HTTPRequest(host: "api.nhie.io", path: "/v1/statements/random") }
            .then { $0.fetchJSONAsync(as: NeverHaveIEverStatement.self) }
    }
}
