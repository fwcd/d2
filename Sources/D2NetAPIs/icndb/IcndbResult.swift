public struct IcndbResult: Codable {
    public let type: String?
    public let value: Joke?
    
    public struct Joke: Codable {
        public let id: Int
        public let joke: String
    }
}
