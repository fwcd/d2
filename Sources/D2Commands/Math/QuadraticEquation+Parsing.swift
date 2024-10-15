import Logging
import Utils
import RegexBuilder

fileprivate let log = Logger(label: "D2Commands.QuadraticEquation+Parsing")

nonisolated(unsafe) private let tokenPattern = #/(?<operator>[+\-=])|(?<rational>[\d/\.]+)|(?<power>x(?:\^(?<exponent>\d+))?)/#

// TODO: Factor out general polynomial (equation) parser

private typealias Token = (Substring, operator: Substring?, rational: Substring?, power: Substring?, exponent: Substring?)
private typealias Monomial = (coefficient: Rational, exponent: Int)

private func peekOperator(from tokens: TokenIterator<Token>) throws -> String {
    guard let token = tokens.peek()?.operator else { throw QuadraticEquationParseError.expectedOperator(tokens.peek()?.0) }
    return String(token)
}

private func parseRational(from tokens: TokenIterator<Token>) throws -> Rational {
    var sign: Rational = 1
    if (try? peekOperator(from: tokens)) == "-" {
        sign = -1
        tokens.next()
    }
    guard let token = tokens.peek()?.rational,
          let rational = Rational(String(token)) else { throw QuadraticEquationParseError.expectedRational(tokens.peek()?.0) }
    tokens.next()
    return sign * rational
}

private func parsePower(from tokens: TokenIterator<Token>) throws -> Int {
    guard tokens.peek()?.power != nil else { throw QuadraticEquationParseError.expectedPower(tokens.peek()?.0) }
    let exponent = tokens.peek()?.exponent
    tokens.next()
    return exponent.flatMap { Int($0) } ?? 1
}

private func parseMonomial(from tokens: TokenIterator<Token>) throws -> Monomial {
    let coefficient = try? parseRational(from: tokens)
    let exponent = try? parsePower(from: tokens)
    guard coefficient != nil || exponent != nil else { throw QuadraticEquationParseError.expectedMonomial(tokens.peek()?.0) }
    return (coefficient: coefficient ?? 1, exponent: exponent ?? 0)
}

private func parsePolynomial(from tokens: TokenIterator<Token>) throws -> [Monomial] {
    var polynomial: [Monomial] = []
    var sign: Rational = 1
    while let monomial = try? parseMonomial(from: tokens) {
        polynomial.append((coefficient: sign * monomial.coefficient, exponent: monomial.exponent))
        let op = try? peekOperator(from: tokens)
        if op == "+" {
            sign = 1
        } else if op == "-" {
            sign = -1
        } else {
            break
        }
        tokens.next()
    }
    return polynomial
}

private func parseEquation(from tokens: TokenIterator<Token>) throws -> (lhs: [Monomial], rhs: [Monomial]) {
    let lhs = try parsePolynomial(from: tokens)
    let op = try peekOperator(from: tokens)
    guard op == "=" else { throw QuadraticEquationParseError.expectedEquals(tokens.peek()?.0) }
    tokens.next()
    let rhs = try parsePolynomial(from: tokens)
    return (lhs: lhs, rhs: rhs)
}

extension QuadraticEquation {
    init(parsing raw: String) throws {
        let tokens = raw.matches(of: tokenPattern).map(\.output)
        let (lhs, rhs) = try parseEquation(from: TokenIterator(tokens))

        let combined = lhs + rhs.map { (coefficient: -$0.coefficient, exponent: $0.exponent) }
        let grouped = Dictionary(grouping: combined, by: \.exponent).mapValues { $0.map(\.coefficient).reduce(0, +) }

        guard let deg = grouped.keys.max() else {
            throw QuadraticEquationParseError.noCoefficients
        }

        guard deg <= 2 else {
            throw QuadraticEquationParseError.degreeGreaterThan2
        }

        self.init(
            a: grouped[2] ?? 0,
            b: grouped[1] ?? 0,
            c: grouped[0] ?? 0
        )
    }
}
