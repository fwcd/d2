import Logging
import Utils
import RegexBuilder

fileprivate let log = Logger(label: "D2Commands.QuadraticEquation+Parsing")

fileprivate let rawNumberPattern = #/(?:(?:-\s*)?[\d/\.]+)/#
fileprivate let monomialPattern = Regex {
    ChoiceOf {
        Regex {
            Optionally {
                Capture {
                    rawNumberPattern
                }
            }
            #/\s*(x(?:\^(\d+))?)/#
        }
        Capture {
            rawNumberPattern
        }
    }
}

extension QuadraticEquation {
    init(parsing raw: String) throws {
        let rawEquation = raw.split(separator: "=")
        guard rawEquation.count == 2 else {
            throw QuadraticEquationParseError.notAnEquation
        }

        let lhs = Dictionary(uniqueKeysWithValues: rawEquation[0].matches(of: monomialPattern)
            .compactMap { parseMonomial(from: ($0.1.flatMap { $0 }, $0.2, $0.3.flatMap { $0 }, $0.4)) }
            .map { (c, d) in (d, c) }
            .withoutDuplicates { $0.0 })

        log.info("Parsed polynomial \(lhs.map { "(\($0))" }.joined(separator: " + "))")

        guard let rhs = Rational(rawEquation[1].trimmingCharacters(in: .whitespaces)) else {
            throw QuadraticEquationParseError.rhsIsNotAFraction
        }
        guard let deg = lhs.keys.max() else {
            throw QuadraticEquationParseError.noCoefficients
        }
        guard deg <= 2 else {
            throw QuadraticEquationParseError.degreeGreaterThan2
        }

        self.init(
            a: lhs[2] ?? 0,
            b: lhs[1] ?? 0,
            c: (lhs[0] ?? 0) - rhs
        )
    }
}

fileprivate func parseMonomial(from parsed: (Substring?, Substring?, Substring?, Substring?)) -> (Rational, Int)? {
    Rational(String(parsed.0?.nilIfEmpty ?? parsed.3?.nilIfEmpty ?? "1"))
        .flatMap { coeff in Int(parsed.1?.nilIfEmpty.map { _ in parsed.2?.nilIfEmpty ?? "1" } ?? "0").map { (coeff, $0) } }
}
