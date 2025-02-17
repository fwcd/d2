import Utils

nonisolated(unsafe) private let indentSpecPattern = #/(?:(?<count>\d+)\s+(?<type>tab|space)s?)|(?<fibonacci>fibonacci)/#

public class ReindentCommand: Command {
    public let info = CommandInfo(
        category: .programming,
        shortDescription: "Changes the indentation of a code snippet",
        helpText: "Syntax: [n tabs|n spaces|fibonacci] [code]"
    )

    public init() {}

    private enum IndentSpec {
        case uniform(String)
        case fibonacci

        static func parse(from rawSpec: String) -> Self? {
            guard let parsedSpec = try? indentSpecPattern.firstMatch(in: rawSpec) else {
                return nil
            }

            if parsedSpec.fibonacci != nil {
                return .fibonacci
            } else {
                let count = parsedSpec.count.flatMap { Int($0) } ?? 1
                return switch parsedSpec.type {
                case "tab": .uniform(String(repeating: "\t", count: count))
                case "space": .uniform(String(repeating: " ", count: count))
                default: nil
                }
            }
        }

        func reindent(code: String) -> String {
            let lines = code.components(separatedBy: .newlines)
            guard let baseIndent = lines
                .compactMap({ $0.firstMatch(of: #/^(?<indent>\s+)/#)?.indent })
                .min(by: ascendingComparator(comparing: \.count)) else {
                return code
            }

            return lines
                .map { line in
                    line.firstMatch(of: #/^(?<indent>\s+)(?<rest>.*)/#).map { parsed in
                        apply(to: parsed.indent, baseIndent: baseIndent) + parsed.rest
                    } ?? line
                }
                .joined(separator: "\n")
        }

        private func apply(to indent: Substring, baseIndent: Substring) -> String {
            let depth = indent.count / baseIndent.count
            return generateIndent(depth: depth)
        }

        private func generateIndent(depth: Int) -> String {
            switch self {
            case .uniform(let indent): String(repeating: indent, count: depth)
            case .fibonacci: FibonacciSequence<Int>().prefix(depth).map { String(repeating: " ", count: $0) }.joined()
            }
        }
    }

    public func invoke(with input: RichValue, output: any CommandOutput, context: CommandContext) async {
        guard let rawSpec = input.asText,
              let spec = IndentSpec.parse(from: rawSpec),
              let code = input.asCode else {
            await output.append(errorText: info.helpText!)
            return
        }

        await output.append(.code(spec.reindent(code: code.code), language: code.language))
    }
}
