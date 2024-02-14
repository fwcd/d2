import Utils

public struct UniversitiesQuery {
    public let name: String

    public init(name: String) {
        self.name = name
    }

    public func perform() -> Promise<[University], any Error> {
        Promise.catching { try HTTPRequest(scheme: "http", host: "universities.hipolabs.com", path: "/search", query: ["name": name]) }
            .then { $0.fetchJSONAsync(as: [University].self) }
    }
}
