public protocol ExpressionParser {
    func parse(_ input: String) throws -> any ExpressionASTNode
}
