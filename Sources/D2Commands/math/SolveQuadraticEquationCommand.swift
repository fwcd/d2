import Utils
import RegexBuilder
import Logging

fileprivate let log = Logger(label: "D2Commands.SolveQuadraticEquationCommand")

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

public class SolveQuadraticEquationCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Solves a quadratic equation",
        longDescription: "Solves a quadratic equation of the form ax^2 + bx + c = d",
        requiredPermissionLevel: .basic
    )
    private let latexRenderer = LatexRenderer()
    private var running: Bool = false

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        let rawEquation = input.split(separator: "=")
        guard rawEquation.count == 2 else {
            output.append(errorText: "Make sure that your equation has the form `... = ...`")
            return
        }

        let lhs = Dictionary(uniqueKeysWithValues: rawEquation[0].matches(of: monomialPattern)
            .compactMap { parseMonomial(from: ($0.1.flatMap { $0 }, $0.2, $0.3.flatMap { $0 }, $0.4)) }
            .map { (c, d) in (d, c) }
            .withoutDuplicates { $0.0 })
        log.info("Parsed polynomial \(lhs.map { "(\($0))" }.joined(separator: " + "))")

        guard let rhs = Rational(rawEquation[1].trimmingCharacters(in: .whitespaces)) else {
            output.append(errorText: "Invalid right-hand side! Make sure that it is a fraction.")
            return
        }
        guard let deg = lhs.keys.max() else {
            output.append(errorText: "Your polynomial has no coefficients")
            return
        }
        guard deg <= 2 else {
            output.append(errorText: "Your polynomial should not have a degree greater than 2!")
            return
        }

        let equation = QuadraticEquation(a: lhs[2] ?? 0, b: lhs[1] ?? 0, c: (lhs[0] ?? 0) - rhs)

        guard equation.a != 0 else {
            output.append(errorText: "This is not a (strictly) quadratic equation!")
            return
        }

        let solutions = equation.solutions

        guard solutions.count > 0 else {
            output.append(errorText: "The quadratic equation has no solutions!")
            return
        }

        let formula = "x \\in \\left\\{\(solutions.sorted().map { latexOf(rational: $0) }.joined(separator: ", "))\\right\\}"

        running = true
        latexRenderer.renderImage(from: formula, to: output).listenOrLogError {
            self.running = false
        }
    }

    private func parseMonomial(from parsed: (Substring?, Substring?, Substring?, Substring?)) -> (Rational, Int)? {
        Rational(String(parsed.0?.nilIfEmpty ?? parsed.3?.nilIfEmpty ?? "1"))
            .flatMap { coeff in Int(parsed.1?.nilIfEmpty.map { _ in parsed.2?.nilIfEmpty ?? "1" } ?? "0").map { (coeff, $0) } }
    }
}
