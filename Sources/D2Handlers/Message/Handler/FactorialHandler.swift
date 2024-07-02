import Utils
import Logging
import D2MessageIO

fileprivate let factorialPattern = #/\b(?<operand>\d+)!\b/#
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
                let result = factorial(operand)
                do {
                    try await sink.sendMessage("\(operand)! = \(result.isLessThanOrEqualTo(Double(Int.max)) ? String(Int(result)) : String(result))", to: channelId)
                } catch {
                    log.warning("Could not send factorial message: \(error)")
                }
            }
        }
        return false
    }

    private func factorial(_ n: Int) -> Double {
        (1...n).map(Double.init).reduce(1, *)
    }
}
