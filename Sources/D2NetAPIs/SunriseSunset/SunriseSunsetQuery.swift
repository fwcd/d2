import Utils

public struct SunriseSunsetQuery {
    public let coords: GeoCoordinates

    public init(at coords: GeoCoordinates) {
        self.coords = coords
    }

    public func perform() -> Promise<SunriseSunsetResults, any Error> {
        Promise.catching { try HTTPRequest(host: "api.sunrise-sunset.org", path: "/json", query: ["lat": String(coords.latitude), "lng": String(coords.longitude)]) }
            .then { $0.fetchJSONAsync(as: SunriseSunsetResults.self) }
    }
}
