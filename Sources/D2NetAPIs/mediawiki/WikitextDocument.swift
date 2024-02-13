import Utils

fileprivate let sectionTitlePattern = try! LegacyRegex(from: "=+\\s*([^=\\s]+)\\s*=+")

public struct WikitextDocument: Equatable {
    public let sections: [Section]

    public struct Section: Equatable {
        public let title: String?
        public fileprivate(set) var content: [Node]

        public enum Node: CustomStringConvertible, Equatable {
            case text(String)
            case link([[Node]])
            case template(String, [TemplateParameter])
            case other(String)
            case unknown

            public var description: String {
                switch self {
                    case let .text(text): return text
                    case let .link(values): return "[\(values.map { $0.map { "\($0)" }.joined(separator: " ") }.joined(separator: "|"))]"
                    case let .template(key, nodes): return "{\(key)|\(nodes)}"
                    case let .other(o): return o
                    case .unknown: return "?"
                }
            }

            public enum TemplateParameter: CustomStringConvertible, Equatable {
                case value([Node])
                case keyValue(String, [Node])

                public var description: String {
                    switch self {
                        case let .value(nodes): return "\(nodes)"
                        case let .keyValue(key, nodes): return "\(key)=\(nodes.map { "\($0)" }.joined(separator: " "))"
                    }
                }
            }
        }
    }
}
