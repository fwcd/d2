public struct UrbanDictionaryEntry: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case defid
        case word
        case definition
        case author
        case example
        case thumbsUp = "thumbs_up"
        case thumbsDown = "thumbs_down"
        case permalink
        case soundUrls = "sound_urls"
        case currentVote = "current_vote"
        case writtenOn = "written_on"
    }

    public let defid: Int
    public let word: String
    public let definition: String
    public let author: String?
    public let example: String?
    public let thumbsUp: Int?
    public let thumbsDown: Int?
    public let permalink: String?
    public let soundUrls: [String]?
    public let currentVote: String?
    public let writtenOn: String?
}
