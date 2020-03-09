public struct MinecraftWikiParse: Codable {
    public let parse: Parse
    
    public struct Parse: Codable {
        public let title: String?
        public let pageid: Int?
        public let wikitext: String?
        
        public var wikitextDocument: MinecraftWikitextDocument? { wikitext.flatMap(MinecraftWikitextDocument.init(from:)) }
    }
}
