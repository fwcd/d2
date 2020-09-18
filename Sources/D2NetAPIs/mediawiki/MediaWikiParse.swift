public struct MediaWikiParse: Codable {
    public let parse: Parse

    public struct Parse: Codable {
        public let title: String?
        public let pageid: Int?
        public let wikitext: String?
        public let sections: [Section]?

        public struct Section: Codable {
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
