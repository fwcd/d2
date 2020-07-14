public struct HoogleResult: Codable, Hashable {
    public let url: String?
    public let module: NamedURL?
    public let package: NamedURL?
    public let item: String
    public let type: String?
    public let docs: String?
    
    public struct NamedURL: Codable, Hashable {
        public let url: String?
        public let name: String?
        
        public var markdown: String {
            guard let name = name, let url = url else { return "" }
            return "[\(name)](\(url))"
        }
    }
}
