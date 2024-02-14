public struct Exam: Hashable {
    public let module: Module?
    public let docent: String?
    public let date: String? // TODO: Use Foundation.Date?
    public let location: String?

    public struct Module: Hashable {
        public let code: String?
        public let name: String?
    }
}
