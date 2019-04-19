import Foundation

public struct MapQuestStaticMap {
	public let url: String
	
	public init(
		latitude: Double,
		longitude: Double,
		width: Int = 300,
		height: Int = 300,
		imageType: String = "png",
		zoomLevel: Int = 16
	) throws {
		var formattedURL: String? = nil
		guard let mapQuestKey = storedWebApiKeys?.mapQuest else { throw MapQuestError.missingApiKey("No API key for MapQuest found") }
		
		// TODO: Output a more detailed error message
		mapQuestKey.withCString { key in
			formattedURL = String(
				format: "https://www.mapquestapi.com/staticmap/v4/getmap?key=%s&size=%d,%d&type=map&zoom=%d&scalebar=false&traffic=false&center=%.6f,%.6f&pois=mcenter,%.6f,%.6f",
				key,
				width,
				height,
				zoomLevel,
				latitude,
				longitude,
				latitude,
				longitude
			)
		}
		
		url = formattedURL!
	}
}
