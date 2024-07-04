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

    public func perform() async throws -> WindyResult<WindyWebcams> {
        guard let key = storedNetApiKeys?.windy?.webcams else {
            throw NetApiError.missingApiKey("No API key for Windy webcams")
        }
        let request = try HTTPRequest(
            host: "api.windy.com",
            path: "/api/webcams/v2/list/nearby=\(self.latitude),\(self.longitude),\(self.radius)",
            query: ["key": key]
        )
        return try await request.fetchJSON(as: WindyResult<WindyWebcams>.self)
    }
}
