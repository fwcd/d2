import Logging
import D2MessageIO
import D2Permissions
import Utils

fileprivate let log = Logger(label: "D2Commands.EvaluateExpressionCommand")
fileprivate let flagsPattern = try! LegacyRegex(from: "--(\\S+)")

// TODO: Use Arg API, integrate flags into arg API

public class EvaluateExpressionCommand: StringCommand {
    public let info: CommandInfo
    private let parser: ExpressionParser

    public init(parser: ExpressionParser, name: String) {
        self.parser = parser
        info = CommandInfo(
            category: .math,
            shortDescription: "Evaluates an expression in \(name)",
            longDescription: "Evaluates an expression written in \(name) and outputs the result",
            helpText: "Syntax: [--ast]? [expression]",
            requiredPermissionLevel: .basic
        )
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        let flags = Set<String>(flagsPattern.allGroups(in: input).map { $0[1] })

        do {
            let ast = try parser.parse(flagsPattern.replace(in: input, with: ""))

            if flags.contains("ast") {
                // Render AST only
                try output.append(try ASTRenderer().render(ast: ast), name: "ast.png")
            } else {
                // Evaluate and print result/graph
                let variables = ast.occurringVariables

                if variables.isEmpty {
                    output.append(String(try ast.evaluate()))
                } else if variables.count == 1 {
                    try output.append(try FunctionGraphRenderer(input: variables.first!).render(ast: ast), name: "functionGraph.png")
                } else {
                    output.append(errorText: "Too many unknown variables: `\(variables)`")
                }
            }
        } catch ExpressionError.invalidOperator(let op) {
            output.append(errorText: "Found invalid operator: `\(op)`")
        } catch ExpressionError.tooFewOperands(let op) {
            output.append(errorText: "Operator `\(op)` has too few operands")
        } catch ExpressionError.emptyResult {
            output.append(errorText: "The expression yielded no result")
        } catch {
            output.append(error, errorText: "Error while parsing/evaluating expression")
        }
    }
}
