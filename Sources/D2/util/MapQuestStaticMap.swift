import Foundation

struct MapQuestStaticMap {
	let url: String
	
	init(
		latitude: Double,
		longitude: Double,
		width: Int = 300,
		height: Int = 300,
		imageType: String = "png",
		zoomLevel: Int = 16,
		ellipseFill: Int = 0x70ff0000,
		ellipseColor: Int = 0xff0000,
		ellipseBorderThickness: Int = 2
	) {
		// This formula was found through exponential regression
		let ellipseLocationRadius: Double = 136.7980757 * exp(-0.8830528944 * Double(zoomLevel))
		let ellipseCenterLatitude: Double = latitude
		let ellipseCenterLongitude: Double = longitude
		
		var formattedURL: String? = nil
		
		mapQuestKey.withCString { key in
			formattedURL = String(
				format: "https://www.mapquestapi.com/staticmap/v4/getmap?key=%s&size=%d,%d&type=map&zoom=%d&scalebar=false&traffic=false&center=%.6f,%.6f&ellipse=fill:0x%08x|color:0x%08x|width:%d|%.6f,%.6f,%.6f,%.6f",
				key,
				width,
				height,
				zoomLevel,
				latitude,
				longitude,
				ellipseFill,
				ellipseColor,
				ellipseBorderThickness,
				ellipseCenterLatitude - ellipseLocationRadius,
				ellipseCenterLongitude - ellipseLocationRadius,
				ellipseCenterLatitude + ellipseLocationRadius,
				ellipseCenterLongitude + ellipseLocationRadius
			)
		}
		
		url = formattedURL!
	}
}
