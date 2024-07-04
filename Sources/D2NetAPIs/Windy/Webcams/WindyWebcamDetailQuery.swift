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

    public func perform() async throws -> WindyResult<WindyWebcams> {
        guard let key = storedNetApiKeys?.windy?.webcams else {
            throw NetApiError.missingApiKey("No API key for Windy webcams")
        }
        let request = try HTTPRequest(
            host: "api.windy.com",
            path: "/api/webcams/v2/list/webcam=\(self.id)",
            query: ["show": self.show, "key": key]
        )
        return try await request.fetchJSON(as: WindyResult<WindyWebcams>.self)
    }
}
