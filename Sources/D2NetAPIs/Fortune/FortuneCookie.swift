public struct FortuneCookie: Codable {
    public let fortune: Fortune?
    public let lesson: Lesson?
    public let lotto: Lotto?

    public struct Fortune: Codable {
        public let message: String
        public let id: String
    }

    public struct Lesson: Codable {
        public let english: String
        public let chinese: String
        public let pronunciation: String
        public let id: String
    }

    public struct Lotto: Codable {
        public let id: String
        public let numbers: [Int]
    }
}
