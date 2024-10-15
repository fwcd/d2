import Utils
import D2MessageIO
import D2NetAPIs

public class TranslateCommand: RegexCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Translates text into another language",
        helpText: "Syntax: [target language, e.g. en] [text]",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public let inputPattern = #/(?<targetLanguage>\w+)\s+(?<text>\S.+)/#

    public init() {}

    public func invoke(with input: Input, output: any CommandOutput, context: CommandContext) async {
        let targetLanguage = String(input.targetLanguage)
        let text = String(input.text)

        do {
            let results = try await BingTranslateQuery(targetLanguage: targetLanguage, text: text).perform()
            guard let result = results.first else {
                await output.append(errorText: "Did not find a result")
                return
            }
            guard let translation = result.translations.first else {
                await output.append(errorText: "Did not find a translation")
                return
            }
            await output.append(Embed(
                title: "Translation\(result.detectedLanguage.map { " from `\($0.language)`" } ?? "") to `\(targetLanguage)`",
                description: translation.text
            ))
        } catch {
            await output.append(error, errorText: "Could not translate")
        }
    }
}
