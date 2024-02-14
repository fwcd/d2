import Utils

fileprivate let spacesPattern = #/ +/#

public struct GuitarTabDocument: Equatable {
    public let sections: [Section]

    public struct Section: Equatable {
        public let title: String
        public let nodes: [Node]

        public var text: String { nodes.map(\.text).joined() }
        public var textWithoutChords: String {
            nodes
                .map { $0.textWithoutChords }
                .joined()
                .split(separator: "\n")
                .map { $0.replacingOccurrences(of: "|", with: " ").replacing(spacesPattern, with: " ") }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
        }

        public enum Node: Equatable {
            case text(String)
            case tag(String, [Node])

            public var text: String {
                switch self {
                    case let .text(txt):
                        return txt
                    case let .tag(_, nodes):
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
