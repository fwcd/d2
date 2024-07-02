import Foundation
import Utils

public struct NominatimGeocoder {
    public init() {}

    public func geocode(location: String) async throws -> GeoCoordinates {
        let request = try HTTPRequest(
            scheme: "https",
            host: "nominatim.openstreetmap.org",
            path: "/search",
            query: [
                "q": location,
                "format": "jsonv2",
            ],
            headers: [
                "User-Agent": "D2",
            ]
        )
        let results = try await request.fetchJSON(as: [NominatimGeocodingResult].self)
        guard let result = results.first else {
            throw NominatimGeocodingError.noResults
        }
        guard let coords = result.geoCoordinates else {
            throw NominatimGeocodingError.noGeoCoordinates
        }
        return coords
    }
}
