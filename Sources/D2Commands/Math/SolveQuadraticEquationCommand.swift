import Utils
import Logging

private let log = Logger(label: "D2Commands.SolveQuadraticEquationCommand")

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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let equation = try QuadraticEquation(parsing: input)
            let solutions = equation.solutions

            guard solutions.count > 0 else {
                await output.append(errorText: "The quadratic equation has no solutions!")
                return
            }

            let formula = "x \\in \\left\\{\(solutions.sorted().map { latexOf(rational: $0) }.joined(separator: ", "))\\right\\}"

            running = true
            await latexRenderer.renderImage(from: formula, to: output)
            running = false
        } catch QuadraticEquationParseError.rhsIsNotAFraction {
            await output.append(errorText: "Invalid right-hand side! Make sure that it is a fraction.")
        } catch QuadraticEquationParseError.noCoefficients {
            await output.append(errorText: "Your polynomial has no coefficients")
        } catch QuadraticEquationParseError.degreeGreaterThan2 {
            await output.append(errorText: "Your polynomial should not have a degree greater than 2!")
        } catch {
            await output.append(error, errorText: "Could not parse quadratic equation")
        }
    }
}
