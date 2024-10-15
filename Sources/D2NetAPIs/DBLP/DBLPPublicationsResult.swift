public struct DBLPPublicationsResult: Sendable, Codable {
    public let query: String
    public let status: String
    public let time: Double
    public let completions: Completions
    public let hits: Hits

    public struct Completions: Sendable, Codable {
        public let c: [String]
    }

    public struct Hits: Sendable, Codable {
        public let hit: [Hit]

        public struct Hit: Sendable, Codable {
            public let score: Int
            public let id: Int
            public let info: Info

            public struct Info: Sendable, Codable {
                public let authors: Authors?
                public let title: String
                public let venue: String?
                public let pages: String?
                public let year: Int?
                public let type: String?
                public let key: String?
                public let doi: String?
                public let ee: String?
                public let url: String?

                public struct Authors: Sendable, Codable {
                    public let author: [String]
                }
            }
        }
    }
}
