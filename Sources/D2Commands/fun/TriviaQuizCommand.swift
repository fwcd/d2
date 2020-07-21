import D2NetAPIs
import D2MessageIO

public class TriviaQuizCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Poses a Trivia question",
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true
    )
    public let outputValueType: RichValueType = .embed
    private var openQuestions: [ChannelID: OpenTDBResponse.Trivia] = [:]

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let channelId = context.channel?.id else {
            output.append("No channel ID available")
            return
        }
        guard !openQuestions.keys.contains(channelId) else {
            output.append("Please answer the existing question first!")
            return
        }

        OpenTDBQuery(amount: 1).perform {
            do {
                let response = try $0.get()
                guard let question = response.results.first else {
                    output.append(errorText: "No questions found")
                    return
                }

                output.append(Embed(
                    description: ":earth_africa: **Trivia Question: \(question.question)**",
                    footer: Embed.Footer(text: "Enter one of the following answers: \(question.allAnswers.sorted().map { "`\($0)`" }.joined(separator: ", "))")
                ))

                self.openQuestions[channelId] = question
                context.subscribeToChannel()
            } catch {
                output.append(error, errorText: "Could not perform TDB query")
            }
        }
    }

	public func onSubscriptionMessage(withContent content: String, output: CommandOutput, context: CommandContext) {
        if let channelId = context.channel?.id, let question = openQuestions[channelId] {
            if content == question.correctAnswer {
                output.append(":partying_face: Correct!")
            } else {
                output.append(":person_shrugging: Sorry, the correct answer was `\(question.correctAnswer)`!")
            }
        }

        context.unsubscribeFromChannel()
    }
}
