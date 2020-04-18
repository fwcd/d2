import D2Utils
import D2Permissions
import D2MessageIO
import Foundation
import Logging

fileprivate let log = Logger(label: "D2Commands.AutoLatexCommand")

/** A simple heuristic for detecting "formulas" in messages. Matches a single character. */
fileprivate let formulaPattern = try! Regex(from: "[0-9{}\\+\\-*\\/\\[\\]\\\\|]")
/** Matches text that should be "escaped" when rendering the message as LaTeX. */
fileprivate let textPattern = try! Regex(from: "(?<!\\\\)\\b\\s*\\p{L}[\\p{L}\\s]*")

public class AutoLatexCommand: StringCommand {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Automatically renders messages as LaTeX formulas",
        longDescription: "Automatically replace messages in a channel by LaTeX-rendered versions",
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true
    )
    private let latexRenderer = try? LatexRenderer()
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        if input == "cancel" {
            output.append(":x: Disabled automatic LaTeX-reformatting for this channel!")
            context.unsubscribeFromChannel()
        } else {
            output.append(":pencil: Enabled automatic LaTeX-reformatting for this channel!")
            context.subscribeToChannel()
        }
    }
    
    public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) {
        if content == "cancel autolatex" {
            output.append("This syntax has been deprecated, please use `\(context.commandPrefix)autolatex cancel` to cancel.")
            return
        }
        
        if formulaPattern.matchCount(in: content) > 0, let renderer = latexRenderer {
            do {
                let formula = escapeText(in: content)
                try renderer.renderImage(from: formula, scale: 1.5, onError: { log.warning("\($0)") }) {
                    do {
                        try output.append($0)
                    } catch {
                        log.error("\(error)")
                    }
                }
            } catch {
                log.warning("\(error)")
            }
        }
    }
    
    private func escapeText(in content: String) -> String {
        return textPattern.replace(in: content, with: "\\\\text{$0}")
    }
    
    public func onSuccessfullySent(context: CommandContext) {
        latexRenderer?.cleanUp()
    }
}
