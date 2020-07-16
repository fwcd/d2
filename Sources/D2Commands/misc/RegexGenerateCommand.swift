import Logging

fileprivate let log = Logger(label: "D2Commands.RegexGenerateCommand")

fileprivate enum RegexGenerateError: Error {
    case emptyChoice
}

public class RegexGenerateCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Generates a (somewhat) random string from a regex",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            guard let ast = try RegexNode.parse(from: input) else {
                output.append(errorText: "Please enter a regex!")
                return
            }
            log.info("Parsed regex \(ast)")
            output.append(try generateWord(from: ast))
        } catch {
            output.append(error, errorText: "Could not parse regex!")
        }
    }

    /// Generates a possible word from the given regex.
    private func generateWord(from regex: RegexNode) throws -> String {
        switch regex {
            case .literal(let s): return s
            case .sequence(let s): return try s.map(generateWord(from:)).joined()
            case .choice(let c):
                guard let branch = c.randomElement() else { throw RegexGenerateError.emptyChoice }
                return try generateWord(from: branch)
            case .option(let o):
                return Bool.random() ? try generateWord(from: o) : ""
            case .repetition(let r):
                return try (0..<Int.random(in: 0..<20)).map { _ in try generateWord(from: r) }.joined()
        }
    }
}
