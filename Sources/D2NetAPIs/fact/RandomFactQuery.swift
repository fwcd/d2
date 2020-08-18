import D2Utils

public struct RandomFactQuery {
    public init() {}

    public func perform() -> Promise<Fact, Error> {
        Promise.catching { try HTTPRequest(host: "uselessfacts.jsph.pl", path: "/random.json") }
            .then { $0.fetchJSONAsync(as: Fact.self) }
    }
}
