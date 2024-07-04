import Utils

public struct SunriseSunsetQuery {
    public let coords: GeoCoordinates

    public init(at coords: GeoCoordinates) {
        self.coords = coords
    }

    public func perform() async throws -> SunriseSunsetResults {
        let request = try HTTPRequest(host: "api.sunrise-sunset.org", path: "/json", query: ["lat": String(coords.latitude), "lng": String(coords.longitude)])
        return try await request.fetchJSON(as: SunriseSunsetResults.self)
    }
}
