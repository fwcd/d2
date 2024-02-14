enum InfixExpressionToken: Hashable {
    case number(Double)
    case identifier(String)
    case operatorSymbol(String)
    case openingParenthesis
    case closingParenthesis
}
