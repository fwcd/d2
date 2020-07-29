import D2Utils

public struct FortuneCookieQuery {
    private let fortuneId: String?
    private let lottoId: String?
    private let lessonId: String?
    private let limit: Int?

    public init(fortuneId: String? = nil, lottoId: String? = nil, lessonId: String? = nil, limit: Int? = nil) {
        self.fortuneId = fortuneId
        self.lottoId = lottoId
        self.lessonId = lessonId
        self.limit = limit
    }

    public func perform() -> Promise<[FortuneCookie], Error> {
        do {
            let request = try HTTPRequest(host: "fortunecookieapi.herokuapp.com", path: "/v1/cookie")
            request.fetchJSONAsync(as: [FortuneCookie].self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
