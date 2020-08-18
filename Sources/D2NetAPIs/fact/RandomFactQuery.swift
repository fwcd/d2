import D2Utils

public struct RandomFactQuery {
    private let language: String?

    public init(language: String? = nil) {
        self.language = language
    }

    public func perform() -> Promise<Fact, Error> {
        Promise.catching { try HTTPRequest(host: "uselessfacts.jsph.pl", path: "/random.json", query: language.map { ["language": $0] } ?? [:]) }
            .then { $0.fetchJSONAsync(as: Fact.self) }
    }
}
