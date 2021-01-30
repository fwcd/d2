import D2MessageIO
import D2Permissions

public class DogeSpeakCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Encodes a string in doge speak",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        output.append(dogeSpeak(of: input))
    }

    private func dogeSpeak(of str: String) -> String {
        str
            .split(separator: " ")
            .map { dogeify(word: withoutPunctuation(String($0))) }
            .joined(separator: " ")
    }

    private func dogeify(word: String) -> String {
        let pre: String
        if Int.random(in: 0..<10) < 3 {
            pre = "Wow! "
        } else {
            pre = ""
        }
        return "\(pre)\(["Such", "Very", "Much", "So", "Many"].randomElement()!) \(word)."
    }

    private func withoutPunctuation(_ str: String) -> String {
        [".", ",", "!", "?"].reduce(str) { $0.replacingOccurrences(of: $1, with: "") }
    }
}
