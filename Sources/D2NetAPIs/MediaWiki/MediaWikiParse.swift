public struct MediaWikiParse: Sendable, Codable {
    public let parse: Parse

    public struct Parse: Sendable, Codable {
        public let title: String?
        public let pageid: Int?
        public let wikitext: String?
        public let sections: [Section]?

        public struct Section: Sendable, Codable {
            public let toclevel: Int?
            public let level: String?
            public let line: String?
            public let number: String?
            public let index: String?
            public let fromtitle: String?
            public let byteoffset: Int?
            public let anchor: String?
        }
    }
}
