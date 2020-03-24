import Foundation
import D2MessageIO
import D2Permissions
import D2NetAPIs

public class XkcdCommand: StringCommand {
    public let info = CommandInfo(
        category: .xkcd,
        shortDescription: "Fetches xkcd comics",
        longDescription: "Fetches an xkcd comic",
        helpText: "Syntax: [comic id | 'random']?",
        requiredPermissionLevel: .basic
    )
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        let handler: (Result<XkcdComic, Error>) -> Void = {
            switch $0 {
                case .success(let comic):
                    output.append(Embed(
                        title: "xkcd #\(comic.num): \(comic.title ?? "no title")",
                        url: URL(string: "https://xkcd.com/\(comic.num)")!,
                        image: comic.img.flatMap(URL.init(string:)).map(Embed.Image.init(url:)),
                        footer: comic.alt.map { Embed(text: $0) }
                    ))
                case .failure(let error):
                    output.append(error, errorText: "An error occurred while fetching the comic")
            }
        }

        if input == "random" {
            XkcdQuery().fetchRandom(then: handler)
        } else {
            XkcdQuery().fetch(comicId: Int(input), then: handler)
        }
    }
}
