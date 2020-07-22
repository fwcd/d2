public struct UltimateGuitarTab: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case songId = "song_id"
        case songName = "song_name"
        case artistId = "artist_id"
        case artistName = "artist_name"
        case type
        case part
        case version
        case votes
        case rating
        case date
        case status
        case tonalityName = "tonality_name"
        case artistUrl = "artist_url"
        case tabUrl = "tab_url"
    }

    public let id: Int?
    public let songId: Int?
    public let songName: String?
    public let artistId: Int?
    public let artistName: String?
    public let type: String?
    public let part: String?
    public let version: Int?
    public let votes: Int?
    public let rating: Double?
    public let date: String?
    public let status: String?
    public let tonalityName: String?
    public let artistUrl: String?
    public let tabUrl: String?
}
