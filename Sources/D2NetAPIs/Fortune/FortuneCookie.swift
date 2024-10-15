public struct FortuneCookie: Sendable, Codable {
    public let fortune: Fortune?
    public let lesson: Lesson?
    public let lotto: Lotto?

    public struct Fortune: Sendable, Codable {
        public let message: String
        public let id: String
    }

    public struct Lesson: Sendable, Codable {
        public let english: String
        public let chinese: String
        public let pronunciation: String
        public let id: String
    }

    public struct Lotto: Sendable, Codable {
        public let id: String
        public let numbers: [Int]
    }
}
