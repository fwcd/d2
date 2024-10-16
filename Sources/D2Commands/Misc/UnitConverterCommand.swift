import Foundation
@preconcurrency import GraphViz
@preconcurrency import CairoGraphics
import Utils

nonisolated(unsafe) private let argsPattern = #/(?<value>\S+)\s+(?<src>\S+)\s+to\s*(?<dest>\S+)/#

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
    private var subcommands: [String: (CommandOutput) async -> Void] = [:]

    // The unit conversion graph
    private let edges: [ConvertableUnit: [ConvertableUnit: AnyAsyncBijection<Double>]]

    public init() {
        let originalEdges: [ConvertableUnit: [ConvertableUnit: AnyAsyncBijection<Double>]] = [
            .m: [
                .nm: AnyAsyncBijection(Scaling(by: 1e6)),
                .mm: AnyAsyncBijection(Scaling(by: 1e3)),
                .cm: AnyAsyncBijection(Scaling(by: 1e2)),
                .km: AnyAsyncBijection(Scaling(by: 1e-3)),
                .inch: AnyAsyncBijection(Scaling(by: 39.3701)),
                .foot: AnyAsyncBijection(Scaling(by: 3.28084))
            ],
            .yard: [
                .foot: AnyAsyncBijection(Scaling(by: 3))
            ],
            .mSquared: [
                .nmSquared: AnyAsyncBijection(Scaling(by: 1e12)),
                .mmSquared: AnyAsyncBijection(Scaling(by: 1e6)),
                .cmSquared: AnyAsyncBijection(Scaling(by: 1e4)),
                .hectare: AnyAsyncBijection(Scaling(by: 1e-4)),
                .kmSquared: AnyAsyncBijection(Scaling(by: 1e-6))
            ],
            .acre: [
                .mSquared: AnyAsyncBijection(Scaling(by: 4046.9))
            ],
            .mCubed: [
                .nmCubed: AnyAsyncBijection(Scaling(by: 1e18)),
                .mmCubed: AnyAsyncBijection(Scaling(by: 1e9)),
                .cmCubed: AnyAsyncBijection(Scaling(by: 1e6)),
                .liter: AnyAsyncBijection(Scaling(by: 1e3)),
                .kmCubed: AnyAsyncBijection(Scaling(by: 1e-18))
            ],
            .byte: [
                .bit: AnyAsyncBijection(Scaling(by: 8)),
                .kilobyte: AnyAsyncBijection(Scaling(by: 1e-3)),
                .megabyte: AnyAsyncBijection(Scaling(by: 1e-6)),
                .gigabyte: AnyAsyncBijection(Scaling(by: 1e-9)),
                .terabyte: AnyAsyncBijection(Scaling(by: 1e-12)),
                .petabyte: AnyAsyncBijection(Scaling(by: 1e-15)),
                .exabyte: AnyAsyncBijection(Scaling(by: 1e-18)),
                .zettabyte: AnyAsyncBijection(Scaling(by: 1e-21)),
                .yottabyte: AnyAsyncBijection(Scaling(by: 1e-24)),
                .kibibyte: AnyAsyncBijection(Scaling(by: pow(2, -10))),
                .mebibyte: AnyAsyncBijection(Scaling(by: pow(2, -20))),
                .gibibyte: AnyAsyncBijection(Scaling(by: pow(2, -30))),
                .tebibyte: AnyAsyncBijection(Scaling(by: pow(2, -40))),
                .pebibyte: AnyAsyncBijection(Scaling(by: pow(2, -50))),
                .exbibyte: AnyAsyncBijection(Scaling(by: pow(2, -60))),
                .zebibyte: AnyAsyncBijection(Scaling(by: pow(2, -70))),
                .yobibyte: AnyAsyncBijection(Scaling(by: pow(2, -80)))
            ],
            .g: [
                .ng: AnyAsyncBijection(Scaling(by: 1e6)),
                .mg: AnyAsyncBijection(Scaling(by: 1e3)),
                .kg: AnyAsyncBijection(Scaling(by: 1e-3))
            ],
            .lb: [
                .kg: AnyAsyncBijection(Scaling(by: 0.453_592_37)),
                .oz: AnyAsyncBijection(Scaling(by: 16))
            ],
            .celsius: [
                .kelvin: AnyAsyncBijection(Translation(by: 273.15))
            ],
            .fahrenheit: [
                .celsius: AnyAsyncBijection(Translation(by: -32).then(Scaling(by: 0.555555555555555)))
            ],
            .eur: [
                .cad: AnyAsyncBijection(CurrencyConversion(to: "CAD")),
                .hkd: AnyAsyncBijection(CurrencyConversion(to: "HKD")),
                .isk: AnyAsyncBijection(CurrencyConversion(to: "ISK")),
                .php: AnyAsyncBijection(CurrencyConversion(to: "PHP")),
                .dkk: AnyAsyncBijection(CurrencyConversion(to: "DKK")),
                .huf: AnyAsyncBijection(CurrencyConversion(to: "HUF")),
                .czk: AnyAsyncBijection(CurrencyConversion(to: "CZK")),
                .aud: AnyAsyncBijection(CurrencyConversion(to: "AUD")),
                .ron: AnyAsyncBijection(CurrencyConversion(to: "RON")),
                .sek: AnyAsyncBijection(CurrencyConversion(to: "SEK")),
                .idr: AnyAsyncBijection(CurrencyConversion(to: "IDR")),
                .inr: AnyAsyncBijection(CurrencyConversion(to: "INR")),
                .brl: AnyAsyncBijection(CurrencyConversion(to: "BRL")),
                .rub: AnyAsyncBijection(CurrencyConversion(to: "RUB")),
                .hrk: AnyAsyncBijection(CurrencyConversion(to: "HRK")),
                .jpy: AnyAsyncBijection(CurrencyConversion(to: "JPY")),
                .thb: AnyAsyncBijection(CurrencyConversion(to: "THB")),
                .chf: AnyAsyncBijection(CurrencyConversion(to: "CHF")),
                .sgd: AnyAsyncBijection(CurrencyConversion(to: "SGD")),
                .pln: AnyAsyncBijection(CurrencyConversion(to: "PLN")),
                .bgn: AnyAsyncBijection(CurrencyConversion(to: "BGN")),
                .cny: AnyAsyncBijection(CurrencyConversion(to: "CNY")),
                .nok: AnyAsyncBijection(CurrencyConversion(to: "NOK")),
                .nzd: AnyAsyncBijection(CurrencyConversion(to: "NZD")),
                .zar: AnyAsyncBijection(CurrencyConversion(to: "ZAR")),
                .usd: AnyAsyncBijection(CurrencyConversion(to: "USD")),
                .mxn: AnyAsyncBijection(CurrencyConversion(to: "MXN")),
                .ils: AnyAsyncBijection(CurrencyConversion(to: "ILS")),
                .gbp: AnyAsyncBijection(CurrencyConversion(to: "GBP")),
                .krw: AnyAsyncBijection(CurrencyConversion(to: "KRW")),
                .myr: AnyAsyncBijection(CurrencyConversion(to: "MYR")),
            ]
        ]
        let invertedEdges = Dictionary(grouping: originalEdges.flatMap { (src, es) in es.map { (dest, b) in (dest, src, AnyAsyncBijection(b.inverse)) } }, by: \.0)
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

                do {
                    let data = try await withCheckedThrowingContinuation { continuation in
                        graph.render(using: .fdp, to: .png) {
                            continuation.resume(with: $0)
                        }
                    }
                    try await output.append(CairoImage(pngData: data))
                } catch {
                    await output.append(error, errorText: "Could not render unit conversion graph")
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

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        if let subcommand = subcommands[input] {
            await subcommand(output)
        } else {
            guard let parsedArgs = try? argsPattern.firstMatch(in: input) else {
                await output.append(errorText: info.helpText!)
                return
            }

            let rawValue = String(parsedArgs.value)
            let rawSrcUnit = String(parsedArgs.src)
            let rawDestUnit = String(parsedArgs.dest)

            guard let value = Double(rawValue) else {
                await output.append(errorText: "Not a number: `\(rawValue)`")
                return
            }
            guard let srcUnit = ConvertableUnit.of(rawSrcUnit) else {
                await output.append(errorText: "Invalid source unit `\(rawSrcUnit)`, try one of these: `\(ConvertableUnit.allCases.map(\.rawValue).joined(separator: ", "))`")
                return
            }
            guard let destUnit = ConvertableUnit.of(rawDestUnit) else {
                await output.append(errorText: "Invalid destination unit `\(rawDestUnit)`, try one of these: `\(ConvertableUnit.allCases.map(\.rawValue).joined(separator: ", "))`")
                return
            }

            guard let conversion = shortestPath(from: srcUnit, to: destUnit) else {
                await output.append(errorText: "No conversion between `\(srcUnit)` and `\(destUnit)` found")
                return
            }

            let destValue = await conversion.apply(value)
            await output.append("\(destValue) \(destUnit)")
        }
    }

    private struct Prioritized<T, U>: Comparable, Sendable where T: Sendable, U: Sendable {
        let value: T
        let priority: Int
        let bijection: AnyAsyncBijection<U>

        static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.priority == rhs.priority
        }

        static func <(lhs: Self, rhs: Self) -> Bool {
            lhs.priority < rhs.priority
        }
    }

    private func shortestPath(from srcUnit: ConvertableUnit, to destUnit: ConvertableUnit) -> AnyAsyncBijection<Double>? {
        guard srcUnit != destUnit else {
            return AnyAsyncBijection(IdentityBijection())
        }

        // Uses Dijkstra's algorithm to find the shortest path from the src unit to the dest unit

        var visited = Set<ConvertableUnit>()
        var queue = BinaryHeap<Prioritized<ConvertableUnit, Double>>()
        var current = Prioritized(value: srcUnit, priority: 0, bijection: AnyAsyncBijection(IdentityBijection<Double>()))

        while current.value != destUnit {
            visited.insert(current.value)

            for (neighbor, bijection) in edges[current.value] ?? [:] where !visited.contains(neighbor) {
                queue.insert(Prioritized(value: neighbor, priority: current.priority - 1, bijection: AnyAsyncBijection(bijection.compose(current.bijection))))
            }

            guard let next = queue.popMax() else { return nil }
            current = next
        }

        return current.bijection
    }
}
