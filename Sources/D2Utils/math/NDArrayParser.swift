fileprivate let rawDecimalPattern = "-?\\d+(?:\\.\\d+)?"
fileprivate let rawFractionPattern = "-?\\d+/\\d+"
// Order of rawFractionPattern and rawDecimalPattern below matters since
// otherwise numerator and denominator would get parsed as separate tokens
fileprivate let tokenPattern = try! Regex(from: "[(),]|((?:\(rawFractionPattern))|(?:\(rawDecimalPattern)))")

public struct NDArrayParser {
    public init() {}

    public func parse(_ input: String) throws -> NDArray<Rational> {
        let tokens = tokenize(input)
        return try parseNDArray(from: tokens)
    }

    public func parseMultiple(_ input: String) -> [NDArray<Rational>] {
        let tokens = tokenize(input)
        var ndArrays = [NDArray<Rational>]()

        while let ndArray = try? parseNDArray(from: tokens) {
            ndArrays.append(ndArray)
        }

        return ndArrays
    }

    private func tokenize(_ input: String) -> TokenIterator<String> {
        let rawTokens = tokenPattern.matches(in: input).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return TokenIterator(rawTokens)
    }

    private func parseNDArray(from tokens: TokenIterator<String>) throws -> NDArray<Rational> {
        if let value = try? parseValue(from: tokens) {
            return NDArray(value)
        } else {
            return try NDArray(ndArrays: try parseCommaSeparatedList("nd-array", from: tokens, valueParser: parseNDArray))
        }
    }
    
    private func parseValue(from tokens: TokenIterator<String>) throws -> Rational {
        let token = tokens.peek()
        guard let value = token.flatMap({ Rational($0)?.reduced() }) else { throw NDArrayParserError.unrecognizedToken("Expected value, but got '\(token ?? "nil")'") }
        tokens.next()
        return value
    }
    
    private func parseCommaSeparatedList<T>(_ what: String, from tokens: TokenIterator<String>, valueParser: (TokenIterator<String>) throws -> T) throws -> [T] {
        var values = [T]()
        let lparen = tokens.next()
        guard lparen == "(" else { throw NDArrayParserError.unrecognizedToken("Expected ( while parsing \(what), but got '\(lparen ?? "nil")'") }
        while tokens.peek() != ")" {
            let value = try valueParser(tokens)
            values.append(value)
            if tokens.peek() == "," {
                tokens.next()
                continue
            }
            let rparen = tokens.peek()
            guard rparen == ")" else { throw NDArrayParserError.unrecognizedToken("Expected ) while parsing \(what), but got '\(rparen ?? "nil")'") }
        }
        tokens.next()
        return values
    }
}