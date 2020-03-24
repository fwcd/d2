public struct HoogleResult: Codable {
    public let url: String?
    public let module: NamedURL?
    public let package: NamedURL?
    public let item: String
    public let type: String?
    public let docs: String?
    
    public struct NamedURL: Codable {
        public let url: String
        public let name: String
        
        public var markdown: String { "[\(name)](\(url))" }
    }
}
