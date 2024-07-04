import Utils
import D2MessageIO
import D2NetAPIs

fileprivate let argPattern = #/(?<targetLanguage>\w+)\s+(?<text>\S.+)/#

public class TranslateCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Translates text into another language",
        helpText: "Syntax: [target language, e.g. en] [text]",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard let parsedArgs = try? argPattern.firstMatch(in: input) else {
            await output.append(errorText: info.helpText!)
            return
        }
        let targetLanguage = String(parsedArgs.targetLanguage)
        let text = String(parsedArgs.text)

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
