import Utils
import RegexBuilder

fileprivate let rawOperatorPattern = ChoiceOf(nonEmptyComponents: allExpressionOperators)

/// Matches a single token.
fileprivate let tokenPattern = Regex {
    ChoiceOf {
        // A number
        Capture { #/\d+(?:\.\d+)?/# }
        // An opening parenthesis
        Capture { #/\(/# }
        // A closing parenthesis
        Capture { #/\)/# }
        // An identifier
        Capture { #/[a-zA-Z]+/# }
        // An operator
        Capture { rawOperatorPattern }
    }
}

public struct InfixExpressionParser: ExpressionParser {
    public init() {}

    public func parse(_ input: String) throws -> ExpressionASTNode {
        return try parseExpression(from: TokenIterator(try tokenize(input)), minPrecedence: 0)
    }

    /// Breaks up the input string into tokens that are processed later.
    private func tokenize(_ str: String) throws -> [InfixExpressionToken] {
        return try str.matches(of: tokenPattern)
            .map {
                if let rawNumber = $0.1 { // Parse number
                    guard let value = Double(rawNumber) else { throw ExpressionError.invalidNumber(String(rawNumber)) }
                    return .number(value)
                } else if $0.2 != nil {
                    return .openingParenthesis
                } else if $0.3 != nil {
                    return .closingParenthesis
                } else if let identifier = $0.4 {
                    return .identifier(String(identifier))
                } else if let operatorSymbol = $0.5 {
                    return .operatorSymbol(String(operatorSymbol))
                } else {
                    throw ExpressionError.unrecognizedToken(String($0.0))
                }
            }
    }

    // The parser is based on https://eli.thegreenplace.net/2012/08/02/parsing-expressions-by-precedence-climbing

    /// Parses an atom (such as a parenthesized expression or a literal).
    private func parseAtom(from tokens: TokenIterator<InfixExpressionToken>) throws -> ExpressionASTNode {
        guard let token = tokens.next() else { throw ExpressionError.unexpectedEnd }
        switch token {
            case .number(let value):
                return ConstantNode(value: value)
            case .identifier(let name):
                if let constant = expressionConstants[name] {
                    return constant
                } else {
                    let node = PlaceholderNode(name: name)

                    if integerVariableNames.contains(name) {
                        return FloorNode(value: node)
                    } else {
                        return node
                    }
                }
            case .openingParenthesis:
                let value = try parseExpression(from: tokens, minPrecedence: 0)

                guard (tokens.peek().map { $0 == .closingParenthesis } ?? false) else { throw ExpressionError.parenthesesMismatch("Expected closing parenthesis, but was \(String(describing: tokens.peek()))") }
                tokens.next() // Consume right parenthesis

                return value
            case .operatorSymbol(let rawOperator):
                // Parse unary operator
                guard let op = expressionUnaryOperators[rawOperator] else { throw ExpressionError.invalidOperator(rawOperator) }
                guard op.position == .prefixPosition else { throw ExpressionError.unsupported("Postfix operators are not supported by InfixExpressionParser yet: '\(rawOperator)'") } // TODO

                return op.factory(try parseAtom(from: tokens))
            default:
                throw ExpressionError.unhandledToken(token)
        }
    }

    /// Use precedence climbing a sequence of tokens as an infix expression.
    private func parseExpression(from tokens: TokenIterator<InfixExpressionToken>, minPrecedence: Int) throws -> ExpressionASTNode {
        var result = try parseAtom(from: tokens)

        while case let .operatorSymbol(rawOperator)? = tokens.peek() {
            // The operator symbol should be a binary operator in a well-formed string
            guard let op = expressionBinaryOperators[rawOperator] else { throw ExpressionError.invalidOperator(rawOperator) }
            guard op.precedence >= minPrecedence else { break }
            let nextMinPrecedence: Int

            tokens.next()

            switch op.associativity {
                case .left: nextMinPrecedence = op.precedence + 1
                case .right: nextMinPrecedence = op.precedence
            }

            let rhs = try parseExpression(from: tokens, minPrecedence: nextMinPrecedence)
            result = op.factory(result, rhs)
        }

        return result
    }
}
