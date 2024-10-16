import Utils

public struct WikitextDocument: Equatable, Sendable {
    public let sections: [Section]

    public struct Section: Equatable, Sendable {
        public let title: String?
        public fileprivate(set) var content: [Node]

        public enum Node: CustomStringConvertible, Equatable, Sendable {
            case text(String)
            case link([[Node]])
            case template(String, [TemplateParameter])
            case other(String)
            case unknown

            public var description: String {
                switch self {
                    case let .text(text): text
                    case let .link(values): "[\(values.map { $0.map { "\($0)" }.joined(separator: " ") }.joined(separator: "|"))]"
                    case let .template(key, nodes): "{\(key)|\(nodes)}"
                    case let .other(o): o
                    case .unknown: "?"
                }
            }

            public enum TemplateParameter: CustomStringConvertible, Equatable, Sendable {
                case value([Node])
                case keyValue(String, [Node])

                public var description: String {
                    switch self {
                        case let .value(nodes): "\(nodes)"
                        case let .keyValue(key, nodes): "\(key)=\(nodes.map { "\($0)" }.joined(separator: " "))"
                    }
                }
            }
        }
    }
}
