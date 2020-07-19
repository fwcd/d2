import Foundation
import D2Utils

fileprivate let argsPattern = try! Regex(from: "(\\S+)\\s+(\\S+)\\s+to\\s*(\\S+)")

public class UnitConverterCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Converts between two units",
        requiredPermissionLevel: .basic
    )

    private enum ConvertableUnit: String, Hashable, CaseIterable, CustomStringConvertible {
        // Length
        case nm
        case mm
        case cm
        case m
        case km

        // Area
        case nmSquared = "nm^2"
        case mmSquared = "mm^2"
        case cmSquared = "cm^2"
        case mSquared = "m^2"
        case kmSquared = "km^2"
        case hectare = "ha"
        case acre = "ac"

        // Volume
        case nmCubed = "nm^3"
        case mmCubed = "mm^3"
        case cmCubed = "cm^3"
        case mCubed = "m^3"
        case kmCubed = "km^3"
        case liter = "l"

        // Data size
        case bit
        case byte = "b"
        case kilobyte = "kb"
        case megabyte = "mb"
        case gigabyte = "gb"
        case terabyte = "tb"
        case petabyte = "pb"
        case exabyte = "eb"
        case zettabyte = "zb"
        case yottabyte = "yt"
        case kibibyte = "kib"
        case mebibyte = "mib"
        case gibibyte = "gib"
        case tebibyte = "tib"
        case pebibyte = "pib"
        case exbibyte = "eib"
        case zebibyte = "zib"
        case yobibyte = "yib"

        var description: String { rawValue }
    }

    // The unit conversion graph
    private let edges: [ConvertableUnit: [ConvertableUnit: AnyBijection<Double>]]
    
    public init() {
        let originalEdges: [ConvertableUnit: [ConvertableUnit: AnyBijection<Double>]] = [
            .m: [
                .nm: AnyBijection(Scaling(by: 1e6)),
                .mm: AnyBijection(Scaling(by: 1e3)),
                .cm: AnyBijection(Scaling(by: 1e2)),
                .km: AnyBijection(Scaling(by: 1e-3))
            ],
            .mSquared: [
                .nmSquared: AnyBijection(Scaling(by: 1e12)),
                .mmSquared: AnyBijection(Scaling(by: 1e6)),
                .cmSquared: AnyBijection(Scaling(by: 1e4)),
                .hectare: AnyBijection(Scaling(by: 1e-4)),
                .kmSquared: AnyBijection(Scaling(by: 1e-6))
            ],
            .acre: [
                .mSquared: AnyBijection(Scaling(by: 4046.9))
            ],
            .mCubed: [
                .nmCubed: AnyBijection(Scaling(by: 1e18)),
                .mmCubed: AnyBijection(Scaling(by: 1e9)),
                .cmCubed: AnyBijection(Scaling(by: 1e6)),
                .liter: AnyBijection(Scaling(by: 1e3)),
                .kmCubed: AnyBijection(Scaling(by: 1e-18))
            ],
            .byte: [
                .bit: AnyBijection(Scaling(by: 8)),
                .kilobyte: AnyBijection(Scaling(by: 1e-3)),
                .megabyte: AnyBijection(Scaling(by: 1e-6)),
                .gigabyte: AnyBijection(Scaling(by: 1e-9)),
                .terabyte: AnyBijection(Scaling(by: 1e-12)),
                .petabyte: AnyBijection(Scaling(by: 1e-15)),
                .exabyte: AnyBijection(Scaling(by: 1e-18)),
                .zettabyte: AnyBijection(Scaling(by: 1e-21)),
                .yottabyte: AnyBijection(Scaling(by: 1e-24)),
                .kibibyte: AnyBijection(Scaling(by: pow(2, -10))),
                .mebibyte: AnyBijection(Scaling(by: pow(2, -20))),
                .gibibyte: AnyBijection(Scaling(by: pow(2, -30))),
                .tebibyte: AnyBijection(Scaling(by: pow(2, -40))),
                .pebibyte: AnyBijection(Scaling(by: pow(2, -50))),
                .exbibyte: AnyBijection(Scaling(by: pow(2, -60))),
                .zebibyte: AnyBijection(Scaling(by: pow(2, -70))),
                .yobibyte: AnyBijection(Scaling(by: pow(2, -80)))
            ]
        ]
        let invertedEdges = Dictionary(grouping: originalEdges.flatMap { (src, es) in es.map { (dest, b) in (dest, src, AnyBijection(b.inverse)) } }, by: \.0)
            .mapValues { Dictionary(uniqueKeysWithValues: $0.map { ($0.1, $0.2) }) }
        
        edges = originalEdges.merging(invertedEdges, uniquingKeysWith: { $0.merging($1, uniquingKeysWith: { v, _ in v }) })
        info.helpText = """
            Syntax: `[number] [unit] to [unit]`

            For example:
            - `4 km to m`
            - `3 gb to bit`

            Supported units: \(ConvertableUnit.allCases.map { "`\($0)`" }.joined(separator: ", "))
            """
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argsPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }

        let rawValue = parsedArgs[1]
        let rawSrcUnit = parsedArgs[2]
        let rawDestUnit = parsedArgs[3]

        guard let value = Double(rawValue) else {
            output.append(errorText: "Not a number: `\(rawValue)`")
            return
        }
        guard let srcUnit = ConvertableUnit(rawValue: rawSrcUnit.lowercased()) else {
            output.append(errorText: "Invalid source unit `\(rawSrcUnit)`, try one of these: `\(ConvertableUnit.allCases.map(\.rawValue).joined(separator: ", "))`")
            return
        }
        guard let destUnit = ConvertableUnit(rawValue: rawDestUnit.lowercased()) else {
            output.append(errorText: "Invalid destination unit `\(rawDestUnit)`, try one of these: `\(ConvertableUnit.allCases.map(\.rawValue).joined(separator: ", "))`")
            return
        }

        guard let conversion = shortestPath(from: srcUnit, to: destUnit) else {
            output.append(errorText: "No conversion between `\(srcUnit)` and `\(destUnit)` found")
            return
        }

        let destValue = conversion.apply(value)
        output.append("\(destValue) \(destUnit)")
    }

    private struct Prioritized<T, U>: Comparable {
        let value: T
        let priority: Int
        let bijection: AnyBijection<U>

        static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.priority == rhs.priority
        }

        static func <(lhs: Self, rhs: Self) -> Bool {
            lhs.priority < rhs.priority
        }
    }

    private func shortestPath(from srcUnit: ConvertableUnit, to destUnit: ConvertableUnit) -> AnyBijection<Double>? {
        guard srcUnit != destUnit else {
            return AnyBijection(IdentityBijection())
        }

        // Uses Dijkstra's algorithm to find the shortest path from the src unit to the dest unit
        
        var visited = Set<ConvertableUnit>()
        var queue = BinaryHeap<Prioritized<ConvertableUnit, Double>>()
        var current = Prioritized(value: srcUnit, priority: 0, bijection: AnyBijection(IdentityBijection<Double>()))

        while current.value != destUnit {
            visited.insert(current.value)

            for (neighbor, bijection) in edges[current.value] ?? [:] where !visited.contains(neighbor) {
                queue.insert(Prioritized(value: neighbor, priority: current.priority - 1, bijection: AnyBijection(bijection.compose(current.bijection))))
            }

            guard let next = queue.popMax() else { return nil }
            current = next
        }

        return current.bijection
    }
}
