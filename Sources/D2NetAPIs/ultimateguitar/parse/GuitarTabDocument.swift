public struct GuitarTabDocument: Equatable {
    public let sections: [Section]

    public struct Section: Equatable {
        public let title: String
        public let nodes: [Node]

        public var text: String { nodes.map(\.text).joined() }
        public var textWithoutChords: String { nodes.map(\.textWithoutChords).joined() }

        public enum Node: Equatable {
            case text(String)
            case tag(String, [Node])

            public var text: String {
                switch self {
                    case let .text(txt):
                        return txt
                    case let .tag(tag, nodes):
                        return nodes.map(\.text).joined()
                }
            }
            public var textWithoutChords: String {
                switch self {
                    case let .text(txt):
                        return txt
                    case let .tag(tag, nodes):
                        guard tag != "ch" else { return "" }
                        return nodes.map(\.textWithoutChords).joined()
                }
            }
        }
    }
}
