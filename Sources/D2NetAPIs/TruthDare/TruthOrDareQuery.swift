import Utils

public struct TruthOrDareQuery {
    public let category: Category
    public let type: TDType

    public init(category: Category, type: TDType) {
        self.category = category
        self.type = type
    }

    public enum Category: String, CaseIterable {
        case friendly
        case dirty
    }

    public enum TDType: String, CaseIterable {
        case truth
        case dare
    }

    public func perform() async throws -> TruthOrDare {
        let request = try HTTPRequest(host: "randommer.io", path: "/truth-dare-generator", method: "POST", query: [
            "category": category.rawValue,
            "type": type.rawValue
        ])
        return try await request.fetchJSON(as: TruthOrDare.self)
    }
}
