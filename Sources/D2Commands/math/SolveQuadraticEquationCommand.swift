import Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.SolveQuadraticEquationCommand")

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
        do {
            let equation = try QuadraticEquation(parsing: input)
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
        } catch QuadraticEquationParseError.notAnEquation {
            output.append(errorText: "Make sure that your equation has the form `... = ...`")
        } catch QuadraticEquationParseError.rhsIsNotAFraction {
            output.append(errorText: "Invalid right-hand side! Make sure that it is a fraction.")
        } catch QuadraticEquationParseError.noCoefficients {
            output.append(errorText: "Your polynomial has no coefficients")
        } catch QuadraticEquationParseError.degreeGreaterThan2 {
            output.append(errorText: "Your polynomial should not have a degree greater than 2!")
        } catch {
            output.append(error, errorText: "Could not parse quadratic equation")
        }
    }
}
