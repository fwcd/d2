import Foundation

struct MapQuestGeocoder {
	func geocode(location: String, then: @escaping (Result<GeoCoordinates>) -> Void) {
		let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
		guard let url = URL(string: "https://www.mapquestapi.com/geocoding/v1/address?key=\(mapQuestKey)&location=\(encodedLocation)") else {
			then(.error(MapQuestError.urlError("Error while constructing url from location '\(encodedLocation)'")))
			return
		}
		
		// Source: https://stackoverflow.com/questions/39939143/parse-json-response-with-swift-3
		
		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		
		URLSession.shared.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				then(.error(MapQuestError.httpError(error)))
				return
			}
			do {
				let json = try JSONSerialization.jsonObject(with: data)
				
				guard let jsonDict = json as? [String : Any] else {
					then(.error(MapQuestError.jsonParseError(json, "Top-level object mismatch")))
					return
				}
				guard let rawResults = jsonDict["results"] else {
					then(.error(MapQuestError.jsonParseError(jsonDict, "'results' key is not present")))
					return
				}
				guard let results = rawResults as? [Any] else {
					then(.error(MapQuestError.jsonParseError(rawResults, "'results' key is not an array")))
					return
				}
				guard let rawFirstResult = results[safe: 0] else {
					then(.error(MapQuestError.foundNoMatches("MapQuest geocoder reponse returned no matches")))
					return
				}
				guard let firstResult = rawFirstResult as? [String : Any] else {
					then(.error(MapQuestError.jsonParseError(rawFirstResult, "First geocoding result is not an object")))
					return
				}
				guard let rawLatLng = firstResult["latLng"] else {
					then(.error(MapQuestError.jsonParseError(firstResult, "First geocoding result has no 'latLng'")))
					return
				}
				guard let latLng = rawLatLng as? [String : Double] else {
					then(.error(MapQuestError.jsonParseError(rawLatLng, "'latLng' could not be parsed")))
					return
				}
				guard let latitude = latLng["lat"] else {
					then(.error(MapQuestError.jsonParseError(latLng, "'latLng' has no latitude")))
					return
				}
				guard let longitude = latLng["lng"] else {
					then(.error(MapQuestError.jsonParseError(latLng, "'latLng' has no longitude")))
					return
				}
				
				then(.ok(GeoCoordinates(latitude: latitude, longitude: longitude)))
			} catch {
				then(.error(MapQuestError.jsonIOError(error)))
			}
		}.resume()
	}
}
