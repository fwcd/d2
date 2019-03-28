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
	) {
		var formattedURL: String? = nil
		
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
