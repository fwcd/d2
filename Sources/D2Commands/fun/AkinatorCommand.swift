import D2MessageIO
import D2NetAPIs

public class AkinatorCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Plays the akinator game, also known as '20 Questions'",
        helpText: "Syntax: [cancel]?",
        requiredPermissionLevel: .basic
    )
    private var sessions: [ChannelID: AkinatorSession] = [:]

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id else {
            output.append(errorText: "Not in a channel!")
            return
        }

        if input == "cancel" {
            guard sessions.keys.contains(channelId) else {
                output.append(errorText: "There is no session running on this channel!")
                return
            }

            context.unsubscribeFromChannel()
            output.append("Successfully cancelled game!")
        } else {
            guard !sessions.keys.contains(channelId) else {
                output.append(errorText: "There is already a session running in this channel!")
                return
            }

            AkinatorSession.create().listen {
                do {
                    let (session, question) = try $0.get()
                    output.append(self.embed(of: question))

                    self.sessions[channelId] = session
                    context.subscribeToChannel()
                } catch {
                    output.append(error, errorText: "Could not create Akinator session")
                }
            }
        }

    }

    public func onSubscriptionMessage(with content: String, output: CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id, let session = sessions[channelId] else {
            context.unsubscribeFromChannel()
            return
        }
        guard let answer = AkinatorAnswer(rawValue: content.lowercased()) else {
            output.append(errorText: "Please use one of these answers: \(AkinatorAnswer.allCases.map(\.rawValue))")
            return
        }

        // TODO: Display guess once ready and unsubscribe

        session.answer(with: answer).listen {
            do {
                let question = try $0.get()
                output.append(self.embed(of: question))
            } catch {
                output.append(error, errorText: "Error while answering")
            }
        }
    }

    private func embed(of question: AkinatorQuestion) -> Embed {
        Embed(
            title: ":genie: Akinator Question",
            description: question.text,
            footer: Embed.Footer(text: "Step: \(question.step), progress: \(Int(question.progression * 100))%")
        )
    }
}
