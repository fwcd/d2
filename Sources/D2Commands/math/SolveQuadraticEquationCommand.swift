import D2Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.SolveQuadraticEquationCommand")

fileprivate let rawFractionPattern = "(?:-\\s*)?\\w+" // More accurate validation is handled by the Rational parser
fileprivate let rawLhsPattern = "\(["x^2", "x"].map { "(?:(\(rawFractionPattern))\\s*\($0)\\s*\\+?\\s*)?" }.joined())(\(rawFractionPattern))?"
fileprivate let rawRhsPattern = "(\(rawFractionPattern))"
fileprivate let equationPattern = try! Regex(from: "\(rawLhsPattern)\\s*=\\s*\(rawRhsPattern)")

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
        guard let parsedEquation = equationPattern.firstGroups(in: input),
            let coefficients = (1...4).sequenceMap({ Rational(parsedEquation[$0].nilIfEmpty ?? "0") }) else {
            output.append(errorText: "Could not parse equation, make sure that it is of the form ax^2 + bx + c = d!")
            return
        }
        guard let renderer = latexRenderer else {
            output.append(errorText: "LaTeX renderer could not be initialized!")
            return
        }

        output.append("Parsed \(coefficients)")

        let (a, b, c, d) = (coefficients[0], coefficients[1], coefficients[2], coefficients[3])

        guard a != 0 else {
            output.append(errorText: "This quadratic equation has no solutions!")
            return
        }

        let root = Rational(approximately: (b * b - 4 * a * (c - d)).asDouble.squareRoot())
        let solutions = [
            -(b + root) / (2 * a),
            -(b - root) / (2 * a)
        ]

        let formula = "x \\in \\left\\{\(solutions.map { latexOf(rational: $0) }.joined(separator: ", "))\\right\\}"

        running = true
        renderLatexImage(with: renderer, from: formula, to: output) {
            self.running = false
        }
    }
}
