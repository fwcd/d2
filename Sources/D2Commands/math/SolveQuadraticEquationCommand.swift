import D2Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.SolveQuadraticEquationCommand")

fileprivate let rawNumberPattern = "(?:(?:-\\s*)?[\\d/\\.]+)"
fileprivate let monomialPattern = try! Regex(from: "(?:(\(rawNumberPattern))?\\s*(x(?:\\^(\\d+))?))|(\(rawNumberPattern))")

public class SolveQuadraticEquationCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Solves a quadratic equation",
        longDescription: "Solves a quadratic equation of the form ax^2 + bx + c = d",
        requiredPermissionLevel: .basic
    )
	private let latexRenderer: LatexRenderer?
    private var running: Bool = false

    public init() {
        do {
			latexRenderer = try LatexRenderer()
		} catch {
			latexRenderer = nil
			log.error("Could not initialize latex renderer: \(error)")
		}
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let equation = input.split(separator: "=")
        guard equation.count == 2 else {
            output.append(errorText: "Make sure that your equation has the form `... = ...`")
            return
        }

        let lhs = Dictionary(uniqueKeysWithValues: monomialPattern.allGroups(in: String(equation[0]))
            .compactMap { parseMonomial(from: $0) }
            .map { (c, d) in (d, c) }
            .withoutDuplicates { $0.0 })
        log.info("Parsed polynomial \(lhs.map { "(\($0))" }.joined(separator: " + "))")

        guard let rhs = Rational(equation[1].trimmingCharacters(in: .whitespaces)) else {
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
        guard let renderer = latexRenderer else {
            output.append(errorText: "LaTeX renderer could not be initialized!")
            return
        }

        let (a, b, c) = (lhs[2] ?? 0, lhs[1] ?? 0, (lhs[0] ?? 0) - rhs)

        guard a != 0 else {
            output.append(errorText: "This is not a (strictly) quadratic equation!")
            return
        }

        let underTheRoot = (b * b - 4 * a * c).asDouble

        guard underTheRoot >= 0 else {
            output.append(errorText: "The quadratic equation has no solutions!")
            return
        }

        let root = Rational(approximately: underTheRoot.squareRoot())
        let solutions: Set<Rational> = [
            -(b + root) / (2 * a),
            -(b - root) / (2 * a)
        ]

        let formula = "x \\in \\left\\{\(solutions.sorted().map { latexOf(rational: $0) }.joined(separator: ", "))\\right\\}"

        running = true
        renderLatexImage(with: renderer, from: formula, to: output).listenOrLogError {
            self.running = false
        }
    }

    private func parseMonomial(from parsed: [String]) -> (Rational, Int)? {
        Rational(parsed[1].nilIfEmpty ?? parsed[4].nilIfEmpty ?? "1")
            .flatMap { coeff in Int(parsed[2].nilIfEmpty.map { _ in parsed[3].nilIfEmpty ?? "1" } ?? "0").map { (coeff, $0) } }
    }
}
