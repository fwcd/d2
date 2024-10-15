public struct OpenThesaurusResults: Sendable, Codable {
    public let metaData: MetaData?
    public let synsets: [SynSet]

    public struct MetaData: Sendable, Codable {
        public let apiVersion: String
        public let warning: String?
        public let copyright: String?
        public let license: String?
        public let source: String?
        public let date: String?
    }

    public struct SynSet: Sendable, Codable {
        public let id: Int
        public let terms: [Term]

        public struct Term: Sendable, Codable {
            public let term: String
        }
    }
}
