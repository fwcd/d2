import D2Utils

fileprivate let sectionTitlePattern = try! Regex(from: "=+\\s*([^=\\s]+)\\s*=+")

public struct MinecraftWikitextDocument {
    public let sections: [Section]

    public struct Section {
        public let title: String?
        public fileprivate(set) var content: [Node]
        
        public enum Node: CustomStringConvertible {
            case text(String)
            case link(String, String?)
            case template(String, [TemplateParameter])
            case other(String)
            case unknown
            
            public var description: String {
                switch self {
                    case let .text(text): return text
                    case let .link(text, target): return "[\(text)\(target.map { "|\($0)" } ?? "")]"
                    case let .template(key, nodes): return "{\(key)|\(nodes)}"
                    case let .other(o): return o
                    case .unknown: return "?"
                }
            }
            
            public enum TemplateParameter: CustomStringConvertible {
                case value([Node])
                case keyValue(String, [Node])
                
                public var description: String {
                    switch self {
                        case let .value(nodes): return "\(nodes)"
                        case let .keyValue(key, nodes): return "\(key)=\(nodes)"
                    }
                }
            }
        }
    }
}
