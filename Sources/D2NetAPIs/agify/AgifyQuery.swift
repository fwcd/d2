import Utils

public struct AgifyQuery {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    public func perform() -> Promise<AgeEstimate, any Error> {
        Promise.catching { try HTTPRequest(host: "api.agify.io", path: "/", query: ["name": name]) }
            .then { $0.fetchJSONAsync(as: AgeEstimate.self) }
    }
}
