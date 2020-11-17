import Foundation
import Utils

public struct MapQuestStaticMap {
    public let url: URL

    public init(
        center: GeoCoordinates? = nil,
        locations: [GeoCoordinates] = [],
        width: Int = 300,
        height: Int = 300,
        imageType: String = "png",
        zoom: Int = 16
    ) throws {
        guard let mapQuestKey = storedNetApiKeys?.mapQuest else { throw NetApiError.missingApiKey("No API key for MapQuest found") }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.mapquestapi.com"
        components.path = "/staticmap/v5/map"

        var query = [
            URLQueryItem(name: "key", value: mapQuestKey),
            URLQueryItem(name: "size", value: "\(width),\(height)"),
            URLQueryItem(name: "zoom", value: String(zoom)),
            URLQueryItem(name: "locations", value: locations.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|"))
        ]

        if let center = center {
            query.append(URLQueryItem(name: "center", value: "\(center.latitude),\(center.longitude)"))
        }

        components.queryItems = query

        guard let url = components.url else { throw NetApiError.urlError(components) }
        self.url = url
    }

    public func download() -> Promise<Data, Error> {
        HTTPRequest(url: url).runAsync()
    }
}
