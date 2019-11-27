import D2Utils
import D2Permissions
import SwiftDiscord
import Foundation

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
        output.append(":pencil: Enabled automatic LaTeX-reformatting for this channel!")
    }
    
    public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) -> CommandSubscriptionAction {
        if content == "cancel autolatex" {
            output.append(":x: Disabled automatic LaTeX-reformatting for this channel!")
            return .cancelSubscription
        }
        
        if formulaPattern.matchCount(in: content) > 0, let renderer = latexRenderer {
            do {
                let formula = escapeText(in: content)
                try renderer.renderImage(from: formula, scale: 1.5, onError: { print($0) }) {
                    do {
                        try output.append($0)
                    } catch {
                        print(error)
                    }
                }
            } catch {
                print(error)
            }
        }
        
        return .continueSubscription
    }
    
    private func escapeText(in content: String) -> String {
        return textPattern.replace(in: content, with: "\\\\text{$0}")
    }
    
    public func onSuccessfullySent(message: DiscordMessage) {
        latexRenderer?.cleanUp()
    }
}
