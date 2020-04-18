public struct WouldYouRather: Codable {
    public let title: String
    public let choicea: String
    public let choiceb: String
    public let link: String?
    public let votes: Int?
    public let nsfw: Bool?
}
