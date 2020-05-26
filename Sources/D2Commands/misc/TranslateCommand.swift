import D2Utils
import D2MessageIO
import D2NetAPIs

fileprivate let argPattern = try! Regex(from: "(\\w+)\\s+(\\S.+)")

public class TranslateCommand: StringCommand {
    public let info = CommandInfo(
        category: .misc,
        shortDescription: "Translates text into another language",
        helpText: "Syntax: [target language, e.g. en] [text]",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard let parsedArgs = argPattern.firstGroups(in: input) else {
            output.append(errorText: info.helpText!)
            return
        }
        let targetLanguage = parsedArgs[1]
        let text = parsedArgs[2]

        BingTranslateQuery(targetLanguage: targetLanguage, text: text).perform {
            switch $0 {
                case .success(let results):
                    guard let result = results.first else {
                        output.append(errorText: "Did not find a result")
                        return
                    }
                    guard let translation = result.translations.first else {
                        output.append(errorText: "Did not find a translation")
                        return
                    }
                    output.append(Embed(
                        title: "Translation\(result.detectedLanguage.map { " from `\($0.language)`" } ?? "") to `\(targetLanguage)`",
                        description: translation.text
                    ))
                case .failure(let error):
                    output.append(error, errorText: "Could not translate")
            }
        }
    }
}