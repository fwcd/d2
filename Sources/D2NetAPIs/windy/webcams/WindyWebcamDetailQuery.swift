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

    public func perform() -> Promise<WindyResult<WindyWebcams>, Error> {
        do {
            guard let token = storedNetApiKeys?.windy?.webcams else {
                throw NetApiError.missingApiKey("No API key for Windy webcams")
            }
            let request = try HTTPRequest(host: "api.windy.com", path: "/api/webcams/v2/list/webcam=\(id)", query: ["show": show, "key": token])
            request.fetchJSONAsync(as: WindyResult<WindyWebcams>.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
