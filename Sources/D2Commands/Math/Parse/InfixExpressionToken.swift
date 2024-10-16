enum InfixExpressionToken: Hashable, Sendable {
    case number(Double)
    case identifier(String)
    case operatorSymbol(String)
    case openingParenthesis
    case closingParenthesis
}
