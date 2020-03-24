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
	
	public func start(then: @escaping (Result<StackOverflowResults<StackOverflowAnswer>, Error>) -> Void) throws {
		try HTTPRequest(host: host, path: "/\(apiVersion)/search", query: [
			"order": "desc",
			"sort": "relevance",
			"intitle": input,
			"site": "stackoverflow",
			"filter": "!bA1d_KuEt(8tau" // Only include title and question ID for each question
		]).fetchJSONAsync(as: StackOverflowResults<StackOverflowQuestion>.self) {
			do {
				guard let questions = try $0.get().items else { throw NetApiError.noResults("No answers found") }
				guard let questionId = questions.first(where: { $0.questionId != nil })?.questionId else { throw NetApiError.noResults("No answer with a question ID found") }
				try HTTPRequest(host: self.host, path: "/\(self.apiVersion)/questions/\(questionId)/answers", query: [
					"order": "desc",
					"sort": "votes",
					"site": "stackoverflow",
					"filter": "!4-(9avC4E*qssXR4f" // Only include owner, title and Markdown body for each answer
				]).fetchJSONAsync(as: StackOverflowResults<StackOverflowAnswer>.self, then: then)
			} catch {
				then(.failure(error))
			}
		}
	}
}
