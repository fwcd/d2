import SwiftDiscord
import Logging
import D2Utils

fileprivate let log = Logger(label: "MatrixMultiplicationCommand")
fileprivate let tokenPattern = try! Regex(from: "[(),]|(?:-?\\d+(?:\\.\\d+)?)")

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
        var current: Matrix<Double>? = nil

        log.debug("Tokens: \(rawTokens)")
        
        do {
            while tokens.peek() != nil {
                let rhs = try parseMatrix(from: tokens)
                if let lhs = current {
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

            if let renderer = latexRenderer {
                let latexFormula = "\\begin{pmatrix}\(product.asArray.map { $0.map { "\($0)" }.joined(separator: " & ") }.joined(separator: " \\\\ "))\\end{pmatrix}"
                log.info("Rendering \(latexFormula)")
                renderLatexPNG(with: renderer, from: latexFormula, to: output)
            } else {
                output.append("\(product)")
            }
        } catch {
            output.append(error, errorText: "\(error)")
        }
    }
    
    private func parseMatrix(from tokens: TokenIterator<String>) throws -> Matrix<Double> {
        Matrix(try parseCommaSeparatedList("matrix", from: tokens, valueParser: parseRow))
    }
    
    private func parseRow(from tokens: TokenIterator<String>) throws -> [Double] {
        try parseCommaSeparatedList("row", from: tokens, valueParser: parseValue)
    }
    
    private func parseValue(from tokens: TokenIterator<String>) throws -> Double {
        let token = tokens.next()
        guard let value = token.flatMap({ Double($0) }) else { throw ExpressionError.unrecognizedToken("Expected value, but got '\(token ?? "nil")'") }
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
