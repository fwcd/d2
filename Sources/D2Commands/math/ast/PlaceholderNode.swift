import Utils

struct PlaceholderNode: ExpressionASTNode {
    let name: String
    let occurringVariables: Set<String>
    var label: String { return name }
    var prefixFunctionNotation: String { return label }
    var infixICNotation: String { return label }

    init(name: String) {
        self.name = name
        occurringVariables = [name]
    }

    func evaluate(with feedDict: [String: Double]) throws -> Double {
        if let value = feedDict[name] {
            return value
        } else {
            throw ExpressionError.noValueForPlaceholder(name)
        }
    }
}
