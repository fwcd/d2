import Foundation
import Logging
import SwiftDiscord
import D2Permissions
import D2NetAPIs

fileprivate let log = Logger(label: "IntegralCalculatorCommand")

public class IntegralCalculatorCommand: StringCommand {
	public let info = CommandInfo(
		category: .math,
		shortDescription: "Solves an integral",
		longDescription: "Solves an integral online and presents a step-by-step solution",
		requiredPermissionLevel: .basic
	)
	private let parser = InfixExpressionParser()
	private let latexRenderer: LatexRenderer?
	
	public init() {
		do {
			latexRenderer = try LatexRenderer()
		} catch {
			latexRenderer = nil
			log.error("Could not initialize latex renderer for IntegralCalculatorCommand: \(error)")
		}
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			let parsedInput = try parser.parse(input)
			guard let integrationVariable = parsedInput.occurringVariables.first else {
				output.append(errorText: "Ambiguous integral due to multiple integration variables")
				return
			}
			
			IntegralCalculatorQuery(params: DefaultIntegralQueryParams(
				expression: parsedInput.infixICNotation,
				expressionCanonical: parsedInput.prefixFunctionNotation,
				intVar: integrationVariable
			)).perform {
				guard case let .success(result) = $0 else {
					if case let .failure(error) = $0 {
						output.append(error, errorText: "An asynchronous error occurred while querying the integral calculator: \(error)")
					}
					return
				}
				
				if let renderer = self.latexRenderer {
					let stepsLatex = result.steps
						.map { $0.replacingOccurrences(of: "$", with: "") }
						.joined(separator: "\\\\")
					renderLatexPNG(with: renderer, from: stepsLatex, to: output)
				} else {
					log.warning("Warning: No LaTeX renderer present in WebIntegralCalculatorCommand")
					output.append(result.steps.joined(separator: "\n"))
				}
			}
		} catch {
			output.append(error, errorText: "An error occurred while parsing or performing the query")
		}
	}
}
