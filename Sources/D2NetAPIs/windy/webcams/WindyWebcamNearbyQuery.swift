import Utils

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

    public func perform() -> Promise<WindyResult<WindyWebcams>, Error> {
        Promise(Result.from(storedNetApiKeys?.windy?.webcams, errorIfNil: NetApiError.missingApiKey("No API key for Windy webcams")))
            .mapCatching { try HTTPRequest(host: "api.windy.com", path: "/api/webcams/v2/list/nearby=\(self.latitude),\(self.longitude),\(self.radius)", query: ["key": $0]) }
            .then { $0.fetchJSONAsync(as: WindyResult<WindyWebcams>.self) }
    }
}
