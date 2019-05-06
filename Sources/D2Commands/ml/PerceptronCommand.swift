import SwiftDiscord
import D2Permissions
import D2Utils

/**
 * Matches a subcommand.
 * 
 * 1. group: subcommand name
 * 2. group: subcommand args
 */
fileprivate let subcommandPattern = try! Regex(from: "(\\S+)(?:\\s+(\\S+))?")
fileprivate let learnPattern = try! Regex(from: "(\\S+)\\s*(\\S+)")

public class PerceptronCommand: StringCommand {
	public let description = "Creates a trains a perceptron"
	public let helpText = """
		Syntax: [subcommand] [args]
		
		Subcommand patterns:
		- reset [dimensions, 2 if not specified]?
		- learn [expected output value] [learning rate]
		- compute [input value 1], [input value 2], ...
		"""
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.vip
	
	private let defaultInputCount: Int
	private var model: SingleLayerPerceptron
	private var subcommands: [String: (String, CommandOutput) throws -> Void] = [:]
	
	public init(defaultInputCount: Int = 2) {
		self.defaultInputCount = defaultInputCount
		model = SingleLayerPerceptron(inputCount: defaultInputCount)
		subcommands = [
			"reset": { [unowned self] in self.reset(args: $0, output: $1) },
			"learn": { [unowned self] in try self.learn(args: $0, output: $1) }
		]
	}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		if let parsedSubcommand = subcommandPattern.firstGroups(in: input) {
			let cmdName = parsedSubcommand[1]
			let cmdArgs = parsedSubcommand[2]
			
			if let subcommand = subcommands[cmdName] {
				do {
					try subcommand(cmdArgs, output)
				} catch MLError.sizeMismatch(let msg) {
					output.append("Size mismatch: \(msg)")
				} catch MLError.illegalState(let msg) {
					output.append("Illegal state: \(msg)")
				} catch MLError.invalidFormat(let msg) {
					output.append("Invalid format: \(msg)")
				} catch {
					output.append("An error occurred: \(error)")
				}
			} else {
				output.append("Unknown subcommand: `\(cmdName)`. Try one of these: `\(subcommands)`")
			}
		}
	}
	
	private func reset(args: String, output: CommandOutput) {
		model = SingleLayerPerceptron(inputCount: defaultInputCount)
	}
	
	private func learn(args: String, output: CommandOutput) throws {
		if let parsedArgs = learnPattern.firstGroups(in: args) {
			guard let expected = Double(parsedArgs[1]) else { throw MLError.invalidFormat("Not a number: \(parsedArgs[1])") }
			guard let learningRate = Double(parsedArgs[2]) else { throw MLError.invalidFormat("Not a number: \(parsedArgs[2])") }
			
			try model.learn(expected: expected, rate: learningRate)
			outputModel(to: output)
		}
	}
	
	private func compute(args: String, output: CommandOutput) throws {
		let inputs = args.split(separator: ",").compactMap { Double($0) }
		guard !inputs.isEmpty else { throw MLError.invalidFormat("Please specify comma-separated input values") }
		
		try model.compute(inputs)
		outputModel(to: output)
	}
	
	private func outputModel(to output: CommandOutput) {
		output.append(DiscordMessage(
			content: model.formula,
			files: [
				// TODO: Plot perceptron
			]
		))
	}
}
