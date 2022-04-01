import Utils

public struct WindyWebcamDetailQuery {
    private let id: String
    private let show: String

    public init(
        id: String,
        show: String = "webcams:image"
    ) {
        self.id = id
        self.show = show
    }

    public func perform() -> Promise<WindyResult<WindyWebcams>, any Error> {
        Promise(Result.from(storedNetApiKeys?.windy?.webcams, errorIfNil: NetApiError.missingApiKey("No API key for Windy webcams")))
            .mapCatching { try HTTPRequest(host: "api.windy.com", path: "/api/webcams/v2/list/webcam=\(self.id)", query: ["show": self.show, "key": $0]) }
            .then { $0.fetchJSONAsync(as: WindyResult<WindyWebcams>.self) }
    }
}
