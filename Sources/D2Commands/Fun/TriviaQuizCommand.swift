import D2NetAPIs
import D2MessageIO
import Utils

public class TriviaQuizCommand: StringCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Poses a Trivia question",
        presented: true,
        requiredPermissionLevel: .basic,
        subscribesToNextMessages: true
    )
    public let outputValueType: RichValueType = .embed
    private var openQuestions: [ChannelID: OpenTDBResponse.Trivia] = [:]

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let channelId = context.channel?.id else {
            await output.append(errorText: "No channel ID available")
            return
        }
        guard !openQuestions.keys.contains(channelId) else {
            await output.append(errorText: "Please answer the existing question first!")
            return
        }

        do {
            let response = try await OpenTDBQuery(amount: 1).perform()
            guard let question = response.results.first else {
                await output.append(errorText: "No questions found")
                return
            }

            await output.append(Embed(
                title: ":earth_africa: Trivia Question",
                description: question.question,
                fields: [
                    Embed.Field(name: "Answers", value: question.allAnswers.sorted().map { "`\($0)`" }.joined(separator: ", ").nilIfEmpty ?? "_none_"),
                    Embed.Field(name: "Category", value: question.category, inline: true),
                    Embed.Field(name: "Difficulty", value: question.difficulty, inline: true)
                ]
            ))

            self.openQuestions[channelId] = question
            context.subscribeToChannel()
        } catch {
            await output.append(error, errorText: "Could not perform TDB query")
        }
    }

    public func onSubscriptionMessage(with content: String, output: any CommandOutput, context: CommandContext) async {
        if let channelId = context.channel?.id, let question = openQuestions[channelId], question.allAnswers.map({ $0.lowercased() }).contains(content.lowercased()) {
            if content.lowercased() == question.correctAnswer.lowercased() {
                await output.append(":partying_face: Correct!")
            } else {
                await output.append(":person_shrugging: Sorry, the correct answer was `\(question.correctAnswer)`!")
            }

            openQuestions[channelId] = nil
            context.unsubscribeFromChannel()
        }
    }
}
