import Foundation
import SwiftDiscord
import D2Permissions
import D2WebAPIs

public class WebIntegralCalculatorCommand: StringCommand {
	public let description = "Solves an integral online and presents a step-by-step solution"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	private let parser = InfixExpressionParser()
	private let latexRenderer: LatexRenderer?
	
	public init() {
		do {
			latexRenderer = try LatexRenderer()
		} catch {
			latexRenderer = nil
			print("Could not initialize latex renderer for WebIntegralCalculatorCommand: \(error)")
		}
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			let parsedInput = try parser.parse(input)
			guard let integrationVariable = parsedInput.occurringVariables.first else {
				output.append("Ambiguous integral due to multiple integration variables")
				return
			}
			
			try IntegralCalculatorQuery(params: IntegralQueryParams(
				expression: parsedInput.infixICNotation,
				expressionCanonical: parsedInput.prefixFunctionNotation,
				intVar: integrationVariable
			)).start {
				guard case let .success(result) = $0 else {
					if case let .failure(err) = $0 {
						print(err)
						output.append("An asynchronous error occurred while querying the integral calculator: \(err)")
					}
					return
				}
				
				if let renderer = self.latexRenderer {
					let stepsLatex = result.steps.joined(separator: "\\\\")
					renderLatexPNG(with: renderer, from: stepsLatex, to: output)
				} else {
					print("Warning: No LaTeX renderer present in WebIntegralCalculatorCommand")
					output.append(result.steps.joined(separator: "\n"))
				}
			}
		} catch WebApiError.apiError(let msg) {
			print(msg)
			output.append("A web API error occurred: \(msg)")
		} catch {
			print(error)
			output.append("An error occurred while parsing or performing the query")
		}
	}
}
