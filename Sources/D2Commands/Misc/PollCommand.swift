import Logging
import Utils
import D2MessageIO
import D2Permissions

fileprivate let log = Logger(label: "D2Commands.PollCommand")

// TODO: Use Arg API

public class PollCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Creates a simple poll",
        longDescription: "Creates a message with the given options and 'reaction buttons' that allow users to vote",
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let interpolatables: [[String]]

    public init(interpolatables: [[String]] = [
        ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"].repeated(count: 2),
        ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"].repeated(count: 2)
    ]) {
        self.interpolatables = interpolatables
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        let components = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        guard components.count >= 1 else {
            await output.append(errorText: "Syntax: [poll text] [zero or more vote options...]")
            return
        }

        do {
            let options = try expand(options: components.dropFirst())

            guard options.count < 10 else {
                await output.append(errorText: "Too many options!")
                return
            }
            guard let sink = context.sink else {
                await output.append(errorText: "Missing client")
                return
            }
            guard let channelId = context.channel?.id else {
                await output.append(errorText: "Missing channel id")
                return
            }

            let reactions: [String]
            var embed = Embed(title: ":bar_chart: Poll: \(components.first!)")

            log.info("Creating poll `\(embed.title!)` with options \(options)")

            if options.isEmpty {
                reactions = ["👍", "👎", "🤷"]
            } else {
                let range = 0..<options.count
                embed.description = "\(range.map { "\n\(numberEmojiOf(digit: $0) ?? "**\($0)**") \(options[$0])" }.joined())"
                reactions = range.compactMap { numberEmojiOf(digit: $0) }
            }

            let sentMessage = try await sink.sendMessage(Message(embed: embed), to: channelId)
            if let nextMessageId = sentMessage?.id {
                for reaction in reactions {
                    try await sink.createReaction(for: nextMessageId, on: channelId, emoji: reaction)
                }
            }
        } catch ExpansionError.noInterpolatableFound {
            await output.append(errorText: "Could not find an interpolatable value before `...`! Try e.g. a weekday.")
        } catch {
            await output.append(error, errorText: "Could not create poll")
        }
    }

    private enum ExpansionError: Error {
        case noInterpolatableFound
    }

    private func expand<S>(options: S) throws -> [String] where S: Sequence, S.Element == String {
        var expanded = [String]()
        var optionIterator = PeekableIterator(options.makeIterator())
        var interpolationIterator: PeekableIterator<Array<String>.Iterator>? = nil

        while let option = interpolationIterator?.next() ?? optionIterator.next() {
            if option == "..." {
                guard let start = expanded.last,
                    let sequence = interpolatables
                        .first(where: { $0.contains { $0.caseInsensitiveCompare(start) == .orderedSame } })?
                        .drop(while: { $0.caseInsensitiveCompare(start) != .orderedSame })
                        .dropFirst() else {
                    throw ExpansionError.noInterpolatableFound
                }
                interpolationIterator = PeekableIterator(Array(sequence).makeIterator())
            } else if optionIterator.peek()?.caseInsensitiveCompare(interpolationIterator?.current ?? "") == .orderedSame {
                interpolationIterator = nil
            } else {
                expanded.append(option)
            }
        }

        return expanded
    }

    private func numberEmojiStringOf(digit: Int) -> String? {
        switch digit {
            case 0: "zero"
            case 1: "one"
            case 2: "two"
            case 3: "three"
            case 4: "four"
            case 5: "five"
            case 6: "six"
            case 7: "seven"
            case 8: "eight"
            case 9: "nine"
            default: nil
        }
    }

    private func numberEmojiOf(digit: Int) -> String? {
        switch digit {
            case 0: "0⃣"
            case 1: "1⃣"
            case 2: "2⃣"
            case 3: "3⃣"
            case 4: "4⃣"
            case 5: "5⃣"
            case 6: "6⃣"
            case 7: "7⃣"
            case 8: "8⃣"
            case 9: "9⃣"
            default: nil
        }
    }
}
