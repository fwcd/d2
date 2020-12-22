import D2NetAPIs
import D2MessageIO

public class FortuneCookieCommand: VoidCommand {
    public let info = CommandInfo(
        category: .fun,
        shortDescription: "Opens a fortune cookie",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(output: CommandOutput, context: CommandContext) {
        FortuneCookieQuery().perform().listen {
            do {
                guard let cookie = try $0.get().first else {
                    output.append(errorText: "No cookies found :(")
                    return
                }
                output.append(Embed(
                    title: ":fortune_cookie: Your Fortune Cookie",
                    fields: [
                        cookie.fortune.map { Embed.Field(name: "Fortune", value: $0.message) },
                        cookie.lesson.map { Embed.Field(name: "Lesson", value: """
                            English: \($0.english)
                            Chinese: \($0.chinese)
                            Pronunciation: \($0.pronunciation)
                            """) },
                        cookie.lotto.map { Embed.Field(name: "Lotto", value: $0.numbers.map { "\($0)" }.joined(separator: " ")) }
                    ].compactMap { $0 }
                ))
            } catch {
                output.append(error, errorText: "Could not fetch fortune cookie")
            }
        }
    }
}
