import Foundation
import GraphViz
import CairoGraphics
import Utils

fileprivate let argsPattern = try! Regex(from: "(\\S+)\\s+(\\S+)\\s+to\\s*(\\S+)")

public class UnitConverterCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .misc,
        shortDescription: "Converts between two units",
        presented: true,
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .text

    private enum ConvertableUnit: String, Hashable, CaseIterable, CustomStringConvertible {
        // Length
        case nm
        case mm
        case cm
        case m
        case km
        case inch = "in"
        case yard = "yd"
        case foot = "ft"

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
        case byte = "B"
        case kilobyte = "KB"
        case megabyte = "MB"
        case gigabyte = "GB"
        case terabyte = "TB"
        case petabyte = "PB"
        case exabyte = "EB"
        case zettabyte = "ZB"
        case yottabyte = "YB"
        case kibibyte = "KiB"
        case mebibyte = "MiB"
        case gibibyte = "GiB"
        case tebibyte = "TiB"
        case pebibyte = "PiB"
        case exbibyte = "EiB"
        case zebibyte = "ZiB"
        case yobibyte = "YiB"

        // Mass
        case ng
        case mg
        case g
        case kg
        case oz
        case lb

        // Temperature
        case kelvin = "K"
        case celsius = "°C"
        case fahrenheit = "°F"

        // Currency
        case eur = "EUR"
        case cad = "CAD"
        case hkd = "HKD"
        case isk = "ISK"
        case php = "PHP"
        case dkk = "DKK"
        case huf = "HUF"
        case czk = "CZK"
        case aud = "AUD"
        case ron = "RON"
        case sek = "SEK"
        case idr = "IDR"
        case inr = "INR"
        case brl = "BRL"
        case rub = "RUB"
        case hrk = "HRK"
        case jpy = "JPY"
        case thb = "THB"
        case chf = "CHF"
        case sgd = "SGD"
        case pln = "pln"
        case bgn = "BGN"
        case cny = "CNY"
        case nok = "NOK"
        case nzd = "NZD"
        case zar = "ZAR"
        case usd = "USD"
        case mxn = "MXN"
        case ils = "ILS"
        case gbp = "GBP"
        case krw = "KRW"
        case myr = "MYR"

        var description: String { rawValue }

        static func of(_ s: String) -> Self? {
            Self(rawValue: s) ?? Self(rawValue: s.lowercased()) ?? Self(rawValue: s.uppercased())
        }
    }
    private var subcommands: [String: (CommandOutput) -> Void] = [:]

    // The unit conversion graph
    private let edges: [ConvertableUnit: [ConvertableUnit: AnyBijection<Double>]]

    public init() {
        let originalEdges: [ConvertableUnit: [ConvertableUnit: AnyBijection<Double>]] = [
            .m: [
                .nm: AnyBijection(Scaling(by: 1e6)),
                .mm: AnyBijection(Scaling(by: 1e3)),
                .cm: AnyBijection(Scaling(by: 1e2)),
                .km: AnyBijection(Scaling(by: 1e-3)),
                .inch: AnyBijection(Scaling(by: 39.3701)),
                .foot: AnyBijection(Scaling(by: 3.28084))
            ],
            .yard: [
                .foot: AnyBijection(Scaling(by: 3))
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
            ],
            .g: [
                .ng: AnyBijection(Scaling(by: 1e6)),
                .mg: AnyBijection(Scaling(by: 1e3)),
                .kg: AnyBijection(Scaling(by: 1e-3))
            ],
            .lb: [
                .kg: AnyBijection(Scaling(by: 0.453_592_37)),
                .oz: AnyBijection(Scaling(by: 16))
            ],
            .celsius: [
                .kelvin: AnyBijection(Translation(by: 273.15))
            ],
            .fahrenheit: [
                .celsius: AnyBijection(Translation(by: -32).then(Scaling(by: 0.555555555555555)))
            ],
            .eur: [
                .cad: AnyBijection(CurrencyConversion(to: "CAD")),
                .hkd: AnyBijection(CurrencyConversion(to: "HKD")),
                .isk: AnyBijection(CurrencyConversion(to: "ISK")),
                .php: AnyBijection(CurrencyConversion(to: "PHP")),
                .dkk: AnyBijection(CurrencyConversion(to: "DKK")),
                .huf: AnyBijection(CurrencyConversion(to: "HUF")),
                .czk: AnyBijection(CurrencyConversion(to: "CZK")),
                .aud: AnyBijection(CurrencyConversion(to: "AUD")),
                .ron: AnyBijection(CurrencyConversion(to: "RON")),
                .sek: AnyBijection(CurrencyConversion(to: "SEK")),
                .idr: AnyBijection(CurrencyConversion(to: "IDR")),
                .inr: AnyBijection(CurrencyConversion(to: "INR")),
                .brl: AnyBijection(CurrencyConversion(to: "BRL")),
                .rub: AnyBijection(CurrencyConversion(to: "RUB")),
                .hrk: AnyBijection(CurrencyConversion(to: "HRK")),
                .jpy: AnyBijection(CurrencyConversion(to: "JPY")),
                .thb: AnyBijection(CurrencyConversion(to: "THB")),
                .chf: AnyBijection(CurrencyConversion(to: "CHF")),
                .sgd: AnyBijection(CurrencyConversion(to: "SGD")),
                .pln: AnyBijection(CurrencyConversion(to: "PLN")),
                .bgn: AnyBijection(CurrencyConversion(to: "BGN")),
                .cny: AnyBijection(CurrencyConversion(to: "CNY")),
                .nok: AnyBijection(CurrencyConversion(to: "NOK")),
                .nzd: AnyBijection(CurrencyConversion(to: "NZD")),
                .zar: AnyBijection(CurrencyConversion(to: "ZAR")),
                .usd: AnyBijection(CurrencyConversion(to: "USD")),
                .mxn: AnyBijection(CurrencyConversion(to: "MXN")),
                .ils: AnyBijection(CurrencyConversion(to: "ILS")),
                .gbp: AnyBijection(CurrencyConversion(to: "GBP")),
                .krw: AnyBijection(CurrencyConversion(to: "KRW")),
                .myr: AnyBijection(CurrencyConversion(to: "MYR")),
            ]
        ]
        let invertedEdges = Dictionary(grouping: originalEdges.flatMap { (src, es) in es.map { (dest, b) in (dest, src, AnyBijection(b.inverse)) } }, by: \.0)
            .mapValues { Dictionary(uniqueKeysWithValues: $0.map { ($0.1, $0.2) }) }

        edges = originalEdges.merging(invertedEdges, uniquingKeysWith: { $0.merging($1, uniquingKeysWith: { v, _ in v }) })
        subcommands = [
            "visualize": { output in
                var graph = Graph(directed: false)
                let nodes = [ConvertableUnit: Node](uniqueKeysWithValues: ConvertableUnit.allCases.map {
                    var node = Node($0.rawValue)
                    node.strokeColor = .named(.white)
                    node.textColor = .named(.white)
                    return ($0, node)
                })

                graph.aspectRatio = .compress
                graph.textColor = .named(.white)
                graph.backgroundColor = .named(.none)

                for node in nodes.values {
                    graph.append(node)
                }


                for (start, neighbors) in originalEdges {
                    for (end, _) in neighbors {
                        var edge = Edge(from: nodes[start]!, to: nodes[end]!)
                        edge.strokeColor = .named(.white)
                        graph.append(edge)
                    }
                }

                graph.render(using: .fdp, to: .png) {
                    do {
                        let data = try $0.get()
                        try output.append(CairoImage(pngData: data))
                    } catch {
                        output.append(error, errorText: "Could not render unit conversion graph")
                    }
                }
            }
        ]

        info.helpText = """
            Syntax: `[number] [unit] to [unit]` or `[subcommand]`

            For example:
            - `4 km to m`
            - `3 gb to bit`

            Supported units: \(ConvertableUnit.allCases.map { "`\($0)`" }.joined(separator: ", "))

            Available subcommands: \(subcommands.keys.map { "`\($0)`" }.joined(separator: ", "))
            """
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        if let subcommand = subcommands[input] {
            subcommand(output)
        } else {
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
            guard let srcUnit = ConvertableUnit.of(rawSrcUnit) else {
                output.append(errorText: "Invalid source unit `\(rawSrcUnit)`, try one of these: `\(ConvertableUnit.allCases.map(\.rawValue).joined(separator: ", "))`")
                return
            }
            guard let destUnit = ConvertableUnit.of(rawDestUnit) else {
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
