import D2Utils

fileprivate let sectionTitlePattern = try! Regex(from: "=+\\s*([^=\\s]+)\\s*=+")

public struct MinecraftWikitextDocument {
    public let sections: [Section]

    public struct Section {
        public let title: String?
        public fileprivate(set) var content: [Node]
        
        public enum Node {
            case text(String)
            case link(String, String?)
            case template(String, [TemplateParameter])
            
            public enum TemplateParameter {
                case value([Node])
                case keyValue(String, [Node])
            }
        }
    }
}
