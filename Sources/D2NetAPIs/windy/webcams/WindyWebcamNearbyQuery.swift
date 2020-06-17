import D2Utils

public struct WindyWebcamNearbyQuery {
    private let latitude: Double
    private let longitude: Double
    private let radius: Int // kms, max. 250

    public init(
        latitude: Double,
        longitude: Double,
        radius: Int
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }

    public func perform(then: @escaping (Result<WindyResult<WindyWebcams>, Error>) -> Void) {
        do {
            guard let token = storedNetApiKeys?.windy?.webcams else {
                throw NetApiError.missingApiKey("No API key for Windy webcams")
            }
            let request = try HTTPRequest(host: "api.windy.com", path: "/api/webcams/v2/list/nearby=\(latitude),\(longitude),\(radius)", query: ["key": token])
            request.fetchJSONAsync(as: WindyResult<WindyWebcams>.self, then: then)
        } catch {
            then(.failure(error))
        }
    }
}
