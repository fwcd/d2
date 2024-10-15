public struct IcndbResult: Sendable, Codable {
    public let type: String?
    public let value: Joke?

    public struct Joke: Sendable, Codable {
        public let id: Int
        public let joke: String
    }
}
