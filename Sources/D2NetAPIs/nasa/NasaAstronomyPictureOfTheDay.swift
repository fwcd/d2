import Foundation

public struct NasaAstronomyPictureOfTheDay: Codable {
    public enum CodingKeys: String, CodingKey {
        case rawDate = "date"
        case explanation
        case title
        case url
        case hdurl
        case mediaType = "media_type"
        case serviceVersion = "service_version"
    }

    public let rawDate: String
    public let explanation: String
    public let title: String
    public let url: URL
    public let hdurl: URL
    public let mediaType: String?
    public let serviceVersion: String?
}
