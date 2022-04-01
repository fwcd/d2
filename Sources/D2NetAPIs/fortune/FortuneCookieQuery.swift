import Utils

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

    public func perform() -> Promise<[FortuneCookie], any Error> {
        Promise.catchingThen {
            let request = try HTTPRequest(host: "fortunecookieapi.herokuapp.com", path: "/v1/cookie")
            return request.fetchJSONAsync(as: [FortuneCookie].self)
        }
    }
}
