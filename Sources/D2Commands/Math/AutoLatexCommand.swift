import Utils
import D2Permissions
import D2MessageIO
import Foundation
import Logging

fileprivate let log = Logger(label: "D2Commands.AutoLatexCommand")

/// A simple heuristic for detecting "formulas" in messages. Matches a single character.
fileprivate let formulaPattern = #/[0-9{}\+\-*\/\[\]\\|]/#
/// Matches text that should be "escaped" when rendering the message as LaTeX.
fileprivate let textPattern = try! LegacyRegex(from: "(?<!\\\\)\\b\\s*\\p{L}[\\p{L}\\s]*") // TODO: Migrate to Swift regex once lookbehind is supported

public class AutoLatexCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Automatically renders messages as LaTeX formulas",
        longDescription: "Automatically replace messages in a channel by LaTeX-rendered versions",
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true
    )
    private let latexRenderer = LatexRenderer()

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        if input == "cancel" {
            output.append(":x: Disabled automatic LaTeX-reformatting for this channel!")
            context.unsubscribeFromChannel()
        } else {
            output.append(":pencil: Enabled automatic LaTeX-reformatting for this channel!")
            context.subscribeToChannel()
        }
    }

    public func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) {
        if content == "cancel autolatex" {
            output.append("This syntax has been deprecated, please use `\(context.commandPrefix)autolatex cancel` to cancel.")
            return
        }

        if !content.matches(of: formulaPattern).isEmpty {
            let formula = escapeText(in: content)
            // TODO: Remove this once onSubscriptionMessage is async
            Task {
                do {
                    let image = try await latexRenderer.renderImage(from: formula, scale: 1.5)
                    try output.append(image)
                } catch {
                    log.error("\(error)")
                }
            }
        }
    }

    private func escapeText(in content: String) -> String {
        return textPattern.replace(in: content, with: "\\\\text{$0}")
    }
}
