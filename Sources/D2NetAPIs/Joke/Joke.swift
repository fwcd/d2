public struct Joke: Sendable, Codable {
    public let id: Int
    public let category: String
    public let lang: String
    public let type: JokeType

    // If type == .twopart
    public let setup: String?
    public let delivery: String?

    // If type == .single
    public let joke: String?
}
