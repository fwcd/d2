public struct GuitarTabDocument: Equatable {
    public let sections: [Section]

    public struct Section: Equatable {
        public let title: String
        public let nodes: [Node]

        public enum Node: Equatable {
            case text(String)
            case tag(String, [Node])
        }
    }
}
