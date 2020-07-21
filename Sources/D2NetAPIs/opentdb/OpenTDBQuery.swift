import D2Utils

public struct OpenTDBQuery {
    private let amount: Int

    public init(amount: Int = 1) {
        self.amount = amount
    }

    public func perform(then: @escaping (Result<OpenTDBResponse, Error>) -> Void) {
        do {
            let request = try HTTPRequest(host: "opentdb.com", path: "/api.php", query: ["amount": String(amount), "encode": "url3986"])
            request.fetchJSONAsync(as: OpenTDBResponse.self) {
                do {
                    var response = try $0.get()
                    response.results = response.results.map {
                        var r = $0
                        r.category = (r.category.removingPercentEncoding ?? r.category).trimmingCharacters(in: .whitespacesAndNewlines)
                        r.type = (r.type.removingPercentEncoding ?? r.type).trimmingCharacters(in: .whitespacesAndNewlines)
                        r.difficulty = (r.difficulty.removingPercentEncoding ?? r.difficulty).trimmingCharacters(in: .whitespacesAndNewlines)
                        r.question = (r.question.removingPercentEncoding ?? r.question).trimmingCharacters(in: .whitespacesAndNewlines)
                        r.correctAnswer = (r.correctAnswer.removingPercentEncoding ?? r.correctAnswer).trimmingCharacters(in: .whitespacesAndNewlines)
                        r.incorrectAnswers = r.incorrectAnswers.compactMap(\.removingPercentEncoding).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        return r
                    }
                    then(.success(response))
                } catch {
                    then(.failure(error))
                }
            }
        } catch {
            then(.failure(error))
        }
    }
}
