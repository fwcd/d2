import SwiftDiscord
import Logging
import D2Utils

fileprivate let log = Logger(label: "MatrixMultiplicationCommand")
fileprivate let rawDecimalPattern = "-?\\d+(?:\\.\\d+)?"
fileprivate let rawFractionPattern = "-?\\d+/\\d+"
// Order of rawFractionPattern and rawDecimalPattern below matters since
// otherwise numerator and denominator would get parsed as separate tokens
fileprivate let tokenPattern = try! Regex(from: "[(),]|((?:\(rawFractionPattern))|(?:\(rawDecimalPattern)))")

public class MatrixMultiplicationCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Multiplies matrices",
        longDescription: "Performs matrix multiplication",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text
    private let latexRenderer: LatexRenderer?
    
    public init() {
        do {
            latexRenderer = try LatexRenderer()
        } catch {
            latexRenderer = nil
            log.warning("Could not create LatexRenderer")
        }
    }
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let rawTokens = tokenPattern.matches(in: input).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let tokens = TokenIterator(rawTokens)
        var current: Matrix<Rational>? = nil

        log.debug("Tokens: \(rawTokens)")
        
        do {
            while tokens.peek() != nil {
                let rhs = try parseMatrix(from: tokens)
                if let lhs = current {
                    log.debug("Right-multiplying \(lhs) by \(rhs)")
                    guard lhs.width == rhs.height else {
                        throw ExpressionError.shapeMismatch("Left width (\(lhs.width)) should match right height (\(rhs.height))")
                    }
                    current = lhs * rhs
                } else {
                    current = rhs
                }
            }
            
            guard let product = current else {
                output.append("Empty product")
                return
            }
            
            log.debug("Computed matrix product \(product)")

            if let renderer = latexRenderer {
                let latexFormula = "\\begin{pmatrix}\(product.asArray.map { $0.map { latexFraction(of: $0) }.joined(separator: " & ") }.joined(separator: " \\\\\\\\ "))\\end{pmatrix}"
                log.info("Rendering \(latexFormula)")
                renderLatexImage(with: renderer, from: latexFormula, to: output, scale: 1.5)
            } else {
                output.append(product.formattedDescription)
            }
        } catch {
            output.append(error, errorText: "\(error)")
        }
    }
    
    private func latexFraction(of rational: Rational) -> String {
        let sign = rational.signum()
        let absReduced = abs(rational.reduced())
        let frac = absReduced.denominator == 1 ? String(absReduced.numerator) : "\\frac{\(absReduced.numerator)}{\(absReduced.denominator)}"
        return "\(sign < 0 ? "-" : "\\phantom{-}")\(frac)"
    }
    
    private func parseMatrix(from tokens: TokenIterator<String>) throws -> Matrix<Rational> {
        Matrix(try parseCommaSeparatedList("matrix", from: tokens, valueParser: parseRow))
    }
    
    private func parseRow(from tokens: TokenIterator<String>) throws -> [Rational] {
        try parseCommaSeparatedList("row", from: tokens, valueParser: parseValue)
    }
    
    private func parseValue(from tokens: TokenIterator<String>) throws -> Rational {
        let token = tokens.next()
        guard let value = token.flatMap({ Rational($0)?.reduced() }) else { throw ExpressionError.unrecognizedToken("Expected value, but got '\(token ?? "nil")'") }
        return value
    }
    
    private func parseCommaSeparatedList<T>(_ what: String, from tokens: TokenIterator<String>, valueParser: (TokenIterator<String>) throws -> T) throws -> [T] {
        var values = [T]()
        let lparen = tokens.next()
        guard lparen == "(" else { throw ExpressionError.unrecognizedToken("Expected ( while parsing \(what), but got '\(lparen ?? "nil")'") }
        while tokens.peek() != ")" {
            let value = try valueParser(tokens)
            values.append(value)
            if tokens.peek() == "," {
                tokens.next()
                continue
            }
            let rparen = tokens.peek()
            guard rparen == ")" else { throw ExpressionError.unrecognizedToken("Expected ) while parsing \(what), but got '\(rparen ?? "nil")'") }
        }
        tokens.next()
        return values
    }
}
