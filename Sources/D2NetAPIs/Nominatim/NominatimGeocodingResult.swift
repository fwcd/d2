import Utils

struct NominatimGeocodingResult: Codable {
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case license
        case osmType = "osm_type"
        case osmId = "osm_id"
        case lat
        case lon
        case category
        case type
        case placeRank = "place_rank"
        case importance
        case addressType = "addresstype"
        case name
        case displayName = "display_name"
        case boundingBox = "boundingbox"
    }

    var placeId: Int?
    var license: String?
    var osmType: String?
    var osmId: Int?
    var lat: String?
    var lon: String?
    var category: String?
    var type: String?
    var placeRank: Int?
    var importance: Double?
    var addressType: String?
    var name: String?
    var displayName: String?
    var boundingBox: [String]?

    var geoCoordinates: GeoCoordinates? {
        guard let lat = lat.flatMap(Double.init),
              let lon = lon.flatMap(Double.init) else { return nil }
        return .init(
            latitude: lat,
            longitude: lon
        )
    }
}
