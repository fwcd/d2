import Utils

public struct RandomFactQuery {
    private let language: String?

    public init(language: String? = nil) {
        self.language = language
    }

    public func perform() async throws -> Fact {
        let request = try HTTPRequest(host: "uselessfacts.jsph.pl", path: "/random.json", query: language.map { ["language": $0] } ?? [:])
        return try await request.fetchJSON(as: Fact.self)
    }
}
