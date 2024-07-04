import Utils

public struct TierVehiclesQuery {
    public let coords: GeoCoordinates
    public let radius: Int

    public init(coords: GeoCoordinates, radius: Int = 100) {
        self.coords = coords
        self.radius = radius
    }

    public func perform() async throws -> TierVehicleResults {
        guard let key = storedNetApiKeys?.tier else { throw NetApiError.missingApiKey("tier") }
        let request = try HTTPRequest(
            host: "platform.tier-services.io",
            path: "/v1/vehicle",
            query: ["lat": String(coords.latitude), "lng": String(coords.longitude), "radius": String(radius)],
            headers: ["X-Api-Key": key]
        )
        return try await request.fetchJSON(as: TierVehicleResults.self)

    }
}
