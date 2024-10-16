import Utils

public struct BingTranslateQuery: Sendable {
    private let sourceLanguage: String?
    private let targetLanguage: String
    private let text: String

    public init(
        sourceLanguage: String? = nil,
        targetLanguage: String,
        text: String
    ) {
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.text = text
    }

    public func perform() async throws -> [BingTranslateResult] {
        let request = try HTTPRequest(scheme: "https", host: "www.bing.com", path: "/ttranslatev3", method: "POST", query: [
            "fromLang": sourceLanguage ?? "auto-detect",
            "to": targetLanguage,
            "text": text
        ])
        return try await request.fetchJSON(as: [BingTranslateResult].self)
    }
}
