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

    public func perform() -> Promise<TruthOrDare, Error> {
        Promise.catching { try HTTPRequest(host: "randommer.io", path: "/truth-dare-generator", method: "POST", query: [
            "category": category.rawValue,
            "type": type.rawValue
        ]) }
            .then { $0.fetchJSONAsync(as: TruthOrDare.self) }
    }
}
