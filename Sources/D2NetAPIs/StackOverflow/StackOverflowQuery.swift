import Utils

public struct StackOverflowQuery: Sendable {
    private let input: String
    private let host: String
    private let apiVersion: String

    public init(
        input: String,
        host: String = "api.stackexchange.com",
        apiVersion: String = "2.2"
    ) throws {
        self.input = input
        self.host = host
        self.apiVersion = apiVersion
    }

    public func perform() async throws -> StackOverflowResults<StackOverflowAnswer> {
        let searchRequest = try HTTPRequest(host: host, path: "/\(apiVersion)/search", query: [
            "order": "desc",
            "sort": "relevance",
            "intitle": input,
            "site": "stackoverflow",
            "filter": "!bA1d_KuEt(8tau" // Only include title and question ID for each question
        ])
        let searchResults = try await searchRequest.fetchJSON(as: StackOverflowResults<StackOverflowQuestion>.self)
        guard let questions = searchResults.items else { throw NetApiError.noResults("No questions found") }
        guard let questionId = questions.first(where: { $0.questionId != nil })?.questionId else { throw NetApiError.noResults("No answer with a question ID found") }

        let answersRequest = try HTTPRequest(host: self.host, path: "/\(self.apiVersion)/questions/\(questionId)/answers", query: [
            "order": "desc",
            "sort": "votes",
            "site": "stackoverflow",
            "filter": "!4-(9avC4E*qssXR4f" // Only include owner, title and Markdown body for each answer
        ])
        let answers = try await answersRequest.fetchJSON(as: StackOverflowResults<StackOverflowAnswer>.self)

        return answers
    }
}
