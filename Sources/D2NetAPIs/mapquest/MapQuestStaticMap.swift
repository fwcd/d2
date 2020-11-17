import Foundation
import Utils

public struct MapQuestStaticMap {
    public let url: URL

    public struct Pin: CustomStringConvertible {
        public let coords: GeoCoordinates
        public let marker: String?

        public var description: String { ["\(coords.latitude),\(coords.longitude)", marker].compactMap { $0 }.joined(separator: "|") }

        public init(coords: GeoCoordinates, marker: String? = nil) {
            self.coords = coords
            self.marker = marker
        }
    }

    public init(
        center: GeoCoordinates? = nil,
        pins: [Pin] = [],
        width: Int = 300,
        height: Int = 300,
        imageType: String = "png",
        zoom: Int = 16,
        defaultMarker: String? = nil // See https://developer.mapquest.com/documentation/static-map-api/v5/getting-started/#marker-types
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
            URLQueryItem(name: "locations", value: pins.map(\.description).joined(separator: "||"))
        ]

        if let center = center {
            query.append(URLQueryItem(name: "center", value: "\(center.latitude),\(center.longitude)"))
        }

        if let defaultMarker = defaultMarker {
            query.append(URLQueryItem(name: "defaultMarker", value: defaultMarker))
        }

        components.queryItems = query

        guard let url = components.url else { throw NetApiError.urlError(components) }
        self.url = url
    }

    public func download() -> Promise<Data, Error> {
        HTTPRequest(url: url).runAsync()
    }
}
