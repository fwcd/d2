import Geodesy
import Utils

public struct FreeGeoIP: Codable {
    public enum CodingKeys: String, CodingKey {
        case ip
        case countryCode = "country_code"
        case countryName = "country_name"
        case regionCode = "region_code"
        case regionName = "region_name"
        case city
        case zipCode = "zip_code"
        case timeZone = "time_zone"
        case latitude
        case longitude
        case metroCode = "metro_code"
    }

    public let ip: String
    public let countryCode: String?
    public let countryName: String?
    public let regionCode: String?
    public let regionName: String?
    public let city: String?
    public let zipCode: String?
    public let timeZone: String?
    public let latitude: Double?
    public let longitude: Double?
    public let metroCode: Int?

    public var coords: Coordinates? {
        latitude.flatMap { lat in longitude.map { lon in .init(latitude: lat, longitude: lon) } }
    }
}
