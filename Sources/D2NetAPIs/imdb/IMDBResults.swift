import Foundation

public struct IMDBResults: Codable {
    public enum CodingKeys: String, CodingKey {
        case entries = "d"
        case query = "q"
        case v
    }

    public let entries: [Entry]
    public let query: String?
    public let v: Int?

    public struct Entry: Codable {
        public enum CodingKeys: String, CodingKey {
            case info = "i"
            case id
            case title = "l"
            case type = "q"
            case rank
            case starring = "s"
            case videos = "v"
            case vt
            case year = "y"
            case years = "yr"
        }

        public let info: Info?
        public let id: String?
        public let title: String?
        public let type: String?
        public let rank: Int?
        public let starring: String?
        public let videos: [Video]?
        public let vt: Int?
        public let year: Int?
        public let years: String?

        public struct Info: Codable {
            public let width: Int?
            public let height: Int?
            public let imageUrl: URL?
        }

        public struct Video: Codable {
            public enum CodingKeys: String, CodingKey {
                case info = "i"
                case id
                case name = "l"
                case length = "s"
            }

            public let info: Info?
            public let id: String
            public let name: String
            public let length: String?
        }
    }
}
