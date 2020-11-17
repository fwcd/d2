import Utils

public struct TierVehiclesQuery {
    public let coords: GeoCoordinates
    public let radius: Int

    public init(coords: GeoCoordinates, radius: Int = 100) {
        self.coords = coords
        self.radius = radius
    }

    public func perform() -> Promise<TierVehicleResults, Error> {
        Promise
            .catching { () -> String in
                guard let key = storedNetApiKeys?.tier else { throw NetApiError.missingApiKey("tier") }
                return key
            }
            .mapCatching { try HTTPRequest(
                host: "platform.tier-services.io",
                path: "/v1/vehicle",
                query: ["lat": String(coords.latitude), "lng": String(coords.longitude), "radius": String(radius)],
                headers: ["X-Api-Key": $0]
            ) }
            .then { $0.fetchJSONAsync(as: TierVehicleResults.self) }

    }
}
