import Foundation
import D2Utils

public struct MapQuestGeocoder {
	public init() {}

	public func geocode(location: String) -> Promise<GeoCoordinates, Error> {
        // TODO: Refactor towards more modern APIs like HTTPRequest and
        //       use Codable structs rather than manually extracting
        //       values from JSON objects.

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
            .then { $0.runAsync() }
            .mapCatching { try JSONSerialization.jsonObject(with: $0) }
            .mapCatching { json in
                let latLng = (json as? [String: Any])
                    .flatMap { $0["results"] }
                    .flatMap { $0 as? [Any] }
                    .flatMap { $0.first }
                    .flatMap { $0 as? [String: Any] }
                    .flatMap { $0["locations"] }
                    .flatMap { $0 as? [Any] }
                    .flatMap { $0.first }
                    .flatMap { $0 as? [String: Any] }
                    .flatMap { $0["latLng"] }
                    .flatMap { $0 as? [String: Double] }

                guard let location = latLng else {
                    throw NetApiError.jsonParseError(String(describing: json), "Could not locate results -> locations -> latLng")
                }
                guard let lat = location["lat"], let lng = location["lng"] else {
                    throw NetApiError.jsonParseError(String(describing: location), "No 'lat'/'lng' keys found")
                }
                return GeoCoordinates(latitude: lat, longitude: lng)
            }
	}
}
