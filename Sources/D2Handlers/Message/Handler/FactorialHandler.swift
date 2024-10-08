import Utils
import Logging
import D2MessageIO

fileprivate let factorialPattern = #/\b(?<operand>\d+)(?<operator>!+)\b/#
fileprivate let log = Logger(label: "D2Handlers.FactorialHandler")

public struct FactorialHandler: MessageHandler {
    private let operandRange: Range<Int>

    public init(operandRange: Range<Int> = 3..<171) {
        self.operandRange = operandRange
    }

    public func handle(message: Message, sink: any Sink) async -> Bool {
        if let channelId = message.channelId,
           let author = message.author,
           !author.bot {
            let matches = message.content.matches(of: factorialPattern)
            if matches.count == 1,
               let match = matches.first,
               let operand = Int(match.operand),
               operandRange.contains(operand) {
                let `operator` = match.output.operator
                let alpha = `operator`.count
                let result = multifactorial(operand, alpha)
                let link: String? = switch alpha {
                    case 1: nil
                    case 2: "https://en.wikipedia.org/wiki/Double_factorial"
                    default: "https://en.wikipedia.org/wiki/Double_factorial#Definitions"
                }
                let formattedOperator = link.map { "[\(`operator`)](<\($0)>)" } ?? "\(`operator`)"
                do {
                    try await sink.sendMessage("\(operand)\(formattedOperator) = \(result.isLessThanOrEqualTo(Double(Int.max)) ? String(Int(result)) : String(result))", to: channelId)
                } catch {
                    log.warning("Could not send factorial message: \(error)")
                }
            }
        }
        return false
    }

    private func multifactorial(_ n: Int, _ alpha: Int) -> Double {
        precondition(alpha >= 1)
        var result: Double = 1
        var n = n
        while n > 0 {
            result *= Double(n)
            n -= alpha
        }
        return result
    }
}
