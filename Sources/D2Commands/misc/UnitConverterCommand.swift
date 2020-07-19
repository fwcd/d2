import D2Utils

fileprivate let argsPattern = try! Regex(from: "(\\S+)\\s+(\\S+)\\s+to\\s*(\\S+)")

public class UnitConverterCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Converts between two units",
        helpText: """
            Syntax: [number] [unit] to [unit]

            For example:
            - `4 km to m`
            """,
        requiredPermissionLevel: .basic
    )

    private enum ConvertableUnit: String, CaseIterable, CustomStringConvertible {
        case nm
        case mm
        case cm
        case m
        case km

        var description: String { rawValue }
    }

    // The unit conversion graph
    private let edges: [ConvertableUnit: [ConvertableUnit: AnyBijection<Rational>]]
    
    public init() {
        let originalEdges: [ConvertableUnit: [ConvertableUnit: AnyBijection<Rational>]] = [
            .m: [
                .nm: AnyBijection(Scaling(by: 1_000_000)),
                .mm: AnyBijection(Scaling(by: 1_000)),
                .cm: AnyBijection(Scaling(by: 100)),
                .km: AnyBijection(Scaling(by: Rational(1, 1_000)))
            ]
        ]
        let invertedEdges = Dictionary(grouping: originalEdges.flatMap { (src, es) in es.map { (dest, b) in (dest, src, AnyBijection(b.inverse)) } }, by: \.0)
            .mapValues { Dictionary(uniqueKeysWithValues: $0.map { ($0.1, $0.2) }) }
        
        edges = originalEdges.merging(invertedEdges, uniquingKeysWith: { k, _ in k })
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }

        let rawValue = parsedArgs[1]
        let rawSrcUnit = parsedArgs[2]
        let rawDestUnit = parsedArgs[3]

        guard let value = Rational(rawValue) else {
            output.append(errorText: "Not a number: `\(rawValue)`")
            return
        }
        guard let srcUnit = ConvertableUnit(rawValue: rawSrcUnit) else {
            output.append(errorText: "Invalid source unit `\(rawSrcUnit)`, try one of these: `\(ConvertableUnit.allCases.map(\.rawValue).joined(separator: ", "))`")
            return
        }
        guard let destUnit = ConvertableUnit(rawValue: rawDestUnit) else {
            output.append(errorText: "Invalid destination unit `\(rawDestUnit)`, try one of these: `\(ConvertableUnit.allCases.map(\.rawValue).joined(separator: ", "))`")
            return
        }

        // TODO: Use path search through graph
        guard let conversion = edges[srcUnit]?[destUnit] else {
            output.append(errorText: "No conversion between `\(srcUnit)` and `\(destUnit)` found")
            return
        }

        let destValue = conversion.apply(value)
        let displays: [String?] = ["\(destValue)", destValue.isDisplayedAsFraction ? "\(destValue.asDouble)" : nil]
        output.append(displays.compactMap { $0 }.map { "\($0) \(destUnit)" }.joined(separator: " = ").nilIfEmpty ?? "_?_")
    }

    private func shortestPath(from srcUnit: ConvertableUnit, to destUnit: ConvertableUnit) -> AnyBijection<Rational> {
        // TODO
        fatalError("TODO")
    }
}
