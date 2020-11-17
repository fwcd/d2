import Utils

public struct SunriseSunsetQuery {
    public let coords: GeoCoordinates

    public init(at coords: GeoCoordinates) {
        self.coords = coords
    }

    public func perform() -> Promise<SunriseSunsetResults, Error> {
        Promise.catching { try HTTPRequest(host: "api.sunrise-sunset.org", path: "/json", query: ["lat": String(coords.latitude), "lon": String(coords.longitude)]) }
            .then { $0.fetchJSONAsync(as: SunriseSunsetResults.self) }
    }
}
