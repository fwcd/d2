import Foundation
import Utils

public struct MapQuestGeocoder {
    public init() {}

    public func geocode(location: String) -> Promise<GeoCoordinates, any Error> {
        Promise.catching { () throws -> HTTPRequest in
            let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            guard let mapQuestKey = storedNetApiKeys?.mapQuest else {
                throw NetApiError.missingApiKey("No API key for MapQuest found")
            }
            guard let url = URL(string: "https://www.mapquestapi.com/geocoding/v1/address?key=\(mapQuestKey)&location=\(encodedLocation)") else {
                throw NetApiError.urlStringError("Error while constructing url from location '\(encodedLocation)'")
            }

            return HTTPRequest(url: url)
        }
            .then { $0.fetchJSONAsync(as: MapQuestGeocoding.self) }
            .mapCatching {
                guard let latLng = $0.results.first?.locations.first?.latLng else {
                    throw NetApiError.jsonParseError(String(describing: $0), "Could not locate results -> locations -> latLng")
                }
                return GeoCoordinates(latitude: latLng.lat, longitude: latLng.lng)
            }
    }
}
