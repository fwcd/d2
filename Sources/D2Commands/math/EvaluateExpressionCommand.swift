import SwiftDiscord
import D2Permissions
import D2Utils

fileprivate let flagsPattern = try! Regex(from: "--(\\S+)")

public class EvaluateExpressionCommand: StringCommand {
	public let description: String
	public let helpText = "Syntax: [--ast]? [expression]"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let parser: ExpressionParser
	
	public init(parser: ExpressionParser, name: String) {
		self.parser = parser
		description = "Evaluates an expression in \(name)"
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		let flags = Set<String>(flagsPattern.allGroups(in: input).map { $0[1] })
		
		do {
			let ast = try parser.parse(input)
			
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
					output.append("Too many unknown variables: `\(variables)`")
				}
			}
		} catch ExpressionError.invalidOperator(let op) {
			output.append("Found invalid operator: `\(op)`")
		} catch ExpressionError.tooFewOperands(let op) {
			output.append("Operator `\(op)` has too few operands")
		} catch ExpressionError.emptyResult {
			output.append("The expression yielded no result")
		} catch {
			print(error)
			output.append("Error while parsing/evaluating expression")
		}
	}
}
