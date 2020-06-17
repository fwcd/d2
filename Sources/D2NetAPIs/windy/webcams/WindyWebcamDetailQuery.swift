import D2Utils

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

    public func perform(then: @escaping (Result<WindyResult<WindyWebcams>, Error>) -> Void) {
        do {
            guard let token = storedNetApiKeys?.windy?.webcams else {
                throw NetApiError.missingApiKey("No API key for Windy webcams")
            }
            let request = try HTTPRequest(host: "api.windy.com", path: "/api/v2/webcams/list/webcam=\(id)", query: ["show": show, "key": token])
            request.fetchJSONAsync(as: WindyResult<WindyWebcams>.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
