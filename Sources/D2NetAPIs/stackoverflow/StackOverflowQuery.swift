import D2Utils

public struct StackOverflowQuery {
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

	public func start() -> Promise<StackOverflowResults<StackOverflowAnswer>, Error> {
		Promise.catching { try HTTPRequest(host: host, path: "/\(apiVersion)/search", query: [
			"order": "desc",
			"sort": "relevance",
			"intitle": input,
			"site": "stackoverflow",
			"filter": "!bA1d_KuEt(8tau" // Only include title and question ID for each question
		]) }
            .then { $0.fetchJSONAsync(as: StackOverflowResults<StackOverflowQuestion>.self) }
            .mapCatching { res -> HTTPRequest in
				guard let questions = res.items else { throw NetApiError.noResults("No questions found") }
				guard let questionId = questions.first(where: { $0.questionId != nil })?.questionId else { throw NetApiError.noResults("No answer with a question ID found") }
				return try HTTPRequest(host: self.host, path: "/\(self.apiVersion)/questions/\(questionId)/answers", query: [
					"order": "desc",
					"sort": "votes",
					"site": "stackoverflow",
					"filter": "!4-(9avC4E*qssXR4f" // Only include owner, title and Markdown body for each answer
				])
			}
            .thenCatching { $0.fetchJSONAsync(as: StackOverflowResults<StackOverflowAnswer>.self) }
	}
}
