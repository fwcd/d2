import Utils
import Geodesy

public struct SunriseSunsetQuery: Sendable {
    public let coords: Coordinates

    public init(at coords: Coordinates) {
        self.coords = coords
    }

    public func perform() async throws -> SunriseSunsetResults {
        let request = try HTTPRequest(host: "api.sunrise-sunset.org", path: "/json", query: ["lat": String(coords.latitude.totalDegrees), "lng": String(coords.longitude.totalDegrees)])
        return try await request.fetchJSON(as: SunriseSunsetResults.self)
    }
}
