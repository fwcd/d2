public struct XkcdComic: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case num
        case title
        case safeTitle = "safe_title"
        case year
        case month
        case day
        case link
        case news
        case transcript
        case alt
        case img
    }

    public let num: Int
    public let title: String?
    public let safeTitle: String?
    public let year: String?
    public let month: String?
    public let day: String?
    public let link: String?
    public let news: String?
    public let transcript: String?
    public let alt: String?
    public let img: String?
}
