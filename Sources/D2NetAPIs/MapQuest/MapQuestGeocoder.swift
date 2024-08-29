import Foundation
import Geodesy
import Utils

public struct MapQuestGeocoder {
    public init() {}

    public func geocode(location: String) async throws -> Coordinates {
        let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        guard let mapQuestKey = storedNetApiKeys?.mapQuest else {
            throw NetApiError.missingApiKey("No API key for MapQuest found")
        }
        guard let url = URL(string: "https://www.mapquestapi.com/geocoding/v1/address?key=\(mapQuestKey)&location=\(encodedLocation)") else {
            throw NetApiError.urlStringError("Error while constructing url from location '\(encodedLocation)'")
        }

        let request = HTTPRequest(url: url)
        let geocoding = try await request.fetchJSON(as: MapQuestGeocoding.self)
        guard let latLng = geocoding.results.first?.locations.first?.latLng else {
            throw NetApiError.jsonParseError(String(describing: geocoding), "Could not locate results -> locations -> latLng")
        }
        return Coordinates(latitude: latLng.lat, longitude: latLng.lng)
    }
}
