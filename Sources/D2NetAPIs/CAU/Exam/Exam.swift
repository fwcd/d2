public struct Exam: Hashable, Sendable {
    public let module: Module?
    public let docent: String?
    public let date: String? // TODO: Use Foundation.Date?
    public let location: String?

    public struct Module: Hashable, Sendable {
        public let code: String?
        public let name: String?
    }
}
