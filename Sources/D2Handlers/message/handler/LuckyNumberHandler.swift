import Utils
import D2MessageIO

fileprivate let numberPattern = try! Regex(from: "\\d+")

public struct LuckyNumberHandler: MessageHandler {
    private let luckyNumber: Int

    public init(luckyNumber: Int) {
        self.luckyNumber = luckyNumber
    }

    public func handle(message: Message, from client: any MessageClient) -> Bool {
        if let channelId = message.channelId {
            let numbers = numberPattern.allGroups(in: message.content).compactMap { Int($0[0]) }
            let sum = numbers.reduce(0, +)
            if sum == luckyNumber {
                client.sendMessage(
                    """
                    All the numbers in your message added up to \(luckyNumber). Congrats!

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
}
