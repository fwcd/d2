import Foundation
import Utils

public struct ChefkochImage: Codable {
    public let urls: [String: ImageURLs]

    public var thumbnailUrl: URL? {
        urls.compactMap { (raw, urls) in Int(raw).flatMap { size in urls.cdn.flatMap(URL.init(string:)).map { (size, $0) } } }
            .filter { (size, _) in size >= 100 }
            .min(by: ascendingComparator(comparing: \.0))?
            .1
    }

    public struct ImageURLs: Codable {
        public let cdn: String?
        public let api: String?
    }
}
