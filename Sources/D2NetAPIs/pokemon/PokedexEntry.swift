public struct PokedexEntry: Codable {
    public let id: Int
    public let name: String?
    public let isNfe: Bool?
    public let types: [String]?
    public let forms: [Form]?
    
    public struct Form: Codable {
        public let name: String?
        public let isNfe: Bool?
        public let types: [String]?
        public let spriteSuffix: String?
    }
}
