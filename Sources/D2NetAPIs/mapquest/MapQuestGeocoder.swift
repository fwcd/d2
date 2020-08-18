import Foundation
import D2Utils

public struct MapQuestGeocoder {
	public init() {}

	public func geocode(location: String) -> Promise<GeoCoordinates, Error> {
        // TODO: Refactor towards more modern APIs like HTTPRequest and
        //       use Codable structs rather than manually extracting
        //       values from JSON objects.

        Promise { then in
            let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            guard let mapQuestKey = storedNetApiKeys?.mapQuest else {
                then(.failure(NetApiError.missingApiKey("No API key for MapQuest found")))
                return
            }

            guard let url = URL(string: "https://www.mapquestapi.com/geocoding/v1/address?key=\(mapQuestKey)&location=\(encodedLocation)") else {
                then(.failure(NetApiError.urlStringError("Error while constructing url from location '\(encodedLocation)'")))
                return
            }

            // Source: https://stackoverflow.com/questions/39939143/parse-json-response-with-swift-3

            HTTPRequest(url: url).runAsync().listen {
                do {
                    let data = try $0.get()
                    let json = try JSONSerialization.jsonObject(with: data)
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
                        then(.failure(NetApiError.jsonParseError(String(describing: json), "Could not locate results -> locations -> latLng")))
                        return
                    }
                    guard let lat = location["lat"], let lng = location["lng"] else {
                        then(.failure(NetApiError.jsonParseError(String(describing: location), "No 'lat'/'lng' keys found")))
                        return
                    }
                    then(.success(GeoCoordinates(latitude: lat, longitude: lng)))
                } catch {
                    then(.failure(NetApiError.jsonIOError(error)))
                }
            }
        }
	}
}
