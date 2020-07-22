public struct GuitarTabDocument {
    public let sections: [Section]

    public struct Section {
        public let title: String
        public let nodes: [Node]

        public enum Node {
            case text(String)
            case tag(String, [Node])
        }
    }
}
