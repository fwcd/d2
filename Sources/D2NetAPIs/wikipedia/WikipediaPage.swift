public struct WikipediaPage: Codable {
    public enum CodingKeys: String, CodingKey {
        case type
        case title
        case displayTitle = "displaytitle"
        case thumbnail
        case lang
        case dir
        case revision
        case tid
        case timestamp
        case description
        case descriptionSource = "description_source"
        case extract
        case extractHtml
    }

    public let type: String
    public let title: String?
    public let displayTitle: String?
    public let thumbnail: Thumbnail?
    public let lang: String?
    public let dir: String?
    public let revision: String?
    public let tid: String?
    public let timestamp: String?
    public let description: String?
    public let descriptionSource: String?
    public let extract: String?
    public let extractHtml: String?
    
    public struct Thumbnail: Codable {
        public let source: String
        public let width: Int
        public let height: Int
    }
}
