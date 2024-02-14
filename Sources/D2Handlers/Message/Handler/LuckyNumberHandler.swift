import Utils
import D2MessageIO

fileprivate let numberPattern = #/\d+/#

public struct LuckyNumberHandler: MessageHandler {
    private let luckyNumbers: Set<Int>
    private let acceptPowerOfTenMultiples: Bool
    private let minimumNumberCount: Int

    public init(luckyNumbers: Set<Int>, acceptPowerOfTenMultiples: Bool = false, minimumNumberCount: Int = 1) {
        self.luckyNumbers = luckyNumbers
        self.acceptPowerOfTenMultiples = acceptPowerOfTenMultiples
        self.minimumNumberCount = minimumNumberCount
    }

    public func handle(message: Message, sink: any Sink) -> Bool {
        if let channelId = message.channelId {
            let numbers = message.content.matches(of: numberPattern).compactMap { Int($0.0) }
            let sum = numbers.reduce(0, +)
            if isLucky(sum) && numbers.count >= minimumNumberCount {
                sink.sendMessage(
                    """
                    All the numbers in your message added up to \(sum). Congrats!
                    ```
                    \(numbers.map { "\($0)" }.reduce1 { "\($0) + \($1)" } ?? "_empty sum_") = \(sum)
                    ```
                    """,
                    to: channelId
                )
            }
        }
        return false
    }

    func isLucky(_ number: Int) -> Bool {
        luckyNumbers.contains(number) || (acceptPowerOfTenMultiples && number >= 10 && number % 10 == 0 && isLucky(number / 10))
    }
}
