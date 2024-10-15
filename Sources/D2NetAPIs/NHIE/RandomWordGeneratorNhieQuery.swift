import Utils

public struct RandomWordGeneratorNhieQuery {
    private struct Response: Sendable, Codable {
        let data: [String: [Question]]

        struct Question: Sendable, Codable {
            enum CodingKeys: String, CodingKey {
                case question = "question_never_have_i_ever"
            }

            let question: String
        }
    }

    public init() {}

    public func perform() async throws -> [NeverHaveIEverStatement] {
        let request = try HTTPRequest(host: "randomwordgenerator.com", path: "/json/question-never-have-i-ever.json")
        let response = try await request.fetchJSON(as: Response.self)
        return response.data.flatMap { (category, statements) in statements.map {
            NeverHaveIEverStatement(
                statement: $0.question,
                category: category
            )
        } }
    }
}
