import D2MessageIO
import D2Permissions
import Utils

/// Matches a subcommand.
///
/// 1. group: subcommand name
/// 2. group: subcommand args
fileprivate let subcommandPattern = #/(?<name>\S+)(?:\s+(?<args>.+))?/#
fileprivate let learnPattern = #/(?<rate>\S+)?/#

/// Matches a data sample of the form ($0, $1).
fileprivate let dataSamplePattern = #/\(\s*([^,]+)\s*,\s*(\S+)\s*\)/#

// TODO: Use the Arg API

public class PerceptronCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Creates and trains a single-layered perceptron",
        longDescription: "Invokes a subcommand on the single-layered perceptron",
        helpText: """
            Syntax: [subcommand] [args]

            Subcommand patterns:
            - reset [dimensions, 2 if not specified]?
            - learn [learning rate]?
            - addData ([input1] [input2], [expected output]) ([input1] [input2], [expected output]) ...
            - compute [input1] [input2] ...
            """,
        requiredPermissionLevel: .vip
    )
    private let defaultInputCount: Int
    private let renderer = PerceptronRenderer()
    private var model: SingleLayerPerceptron
    private var subcommands: [String: (String, CommandOutput) throws -> Void] = [:]

    public init(defaultInputCount: Int = 2) {
        self.defaultInputCount = defaultInputCount
        model = SingleLayerPerceptron(inputCount: defaultInputCount)
        subcommands = [
            "reset": { [unowned self] in self.reset(args: $0, output: $1) },
            "learn": { [unowned self] in try self.learn(args: $0, output: $1) },
            "addData": { [unowned self] in try self.addData(args: $0, output: $1) },
            "compute": { [unowned self] in try self.compute(args: $0, output: $1) }
        ]
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        if let parsedSubcommand = try? subcommandPattern.firstMatch(in: input) {
            let cmdName = String(parsedSubcommand.name)
            let cmdArgs = String(parsedSubcommand.args ?? "")

            if let subcommand = subcommands[cmdName] {
                do {
                    try subcommand(cmdArgs, output)
                } catch MLError.sizeMismatch(let msg) {
                    output.append(errorText: "Size mismatch: \(msg)")
                } catch MLError.illegalState(let msg) {
                    output.append(errorText: "Illegal state: \(msg)")
                } catch MLError.invalidFormat(let msg) {
                    output.append(errorText: "Invalid format: \(msg)")
                } catch {
                    output.append(error)
                }
            } else {
                output.append(errorText: "Unknown subcommand: `\(cmdName)`. Try one of these: `\(subcommands.keys)`")
            }
        } else {
            output.append(errorText: info.helpText!)
        }
    }

    private func reset(args: String, output: any CommandOutput) {
        let dimensions = Int(args) ?? defaultInputCount
        model = SingleLayerPerceptron(inputCount: dimensions)
        output.append("Created a new \(dimensions)-dimensional perceptron")
    }

    private func learn(args: String, output: any CommandOutput) throws {
        if let parsedArgs = try? learnPattern.firstMatch(in: args) {
            let learningRate = Double(parsedArgs.rate ?? "") ?? 0.1

            try model.learn(rate: learningRate)
            try outputModel(to: output)
        } else {
            output.append(errorText: "Unrecognized syntax, try specifying a learning rate")
        }
    }

    private func parseDoubles(in spaceSeparatedStr: String) -> [Double] {
        return spaceSeparatedStr.split(separator: " ").compactMap { Double($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
    }

    private func compute(args: String, output: any CommandOutput) throws {
        let inputs = parseDoubles(in: args)
        guard !inputs.isEmpty else { throw MLError.invalidFormat("Please specify space-separated input values") }

        let outputValue = try model.compute(inputs)
        try outputModel(to: output, outputValue: outputValue)
    }

    private func outputModel(to output: any CommandOutput, outputValue: Double? = nil) throws {
        output.append(.compound([
            .text("\(model.formula)\(outputValue.map { String(format: " = %.3f", $0) } ?? "")"),
            .files(try renderer.render(model: &model).map { [
                Message.FileUpload(data: try $0.pngEncoded(), filename: "perceptron.png", mimeType: "image/png")
            ] } ?? [])
        ]))
    }

    private func addData(args: String, output: any CommandOutput) throws {
        let samples = args.matches(of: dataSamplePattern).compactMap { match in parseDoubles(in: String(match.1)).nilIfEmpty.flatMap { a in Double(match.2).map { b in (a, b) } } }
        guard !samples.isEmpty else { throw MLError.invalidFormat("Please specify space-separated data samples of the form: (number number number..., number), for example: (3.4 2.1, 5.3) (0.1 0, -2) in two dimensions") }

        try model.feedData(samples)
        try outputModel(to: output)
    }
}
