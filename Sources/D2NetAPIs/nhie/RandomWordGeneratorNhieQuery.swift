import Utils

public struct RandomWordGeneratorNhieQuery {
    private struct Response: Codable {
        let data: [String: [String]]
    }

    public init() {}

    public func perform() -> Promise<[NeverHaveIEverStatement], Error> {
        Promise.catching { try HTTPRequest(host: "randomwordgenerator.com", path: "/json/question-never-have-i-ever.json") }
            .then { $0.fetchJSONAsync(as: Response.self) }
            .map {
                $0.data.flatMap { (category, statements) in statements.map {
                    NeverHaveIEverStatement(
                        statement: $0,
                        category: category
                    )
                } }
            }
    }
}
