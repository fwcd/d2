import Foundation
import D2MessageIO
import Utils
import D2NetAPIs

public class XkcdCommand: StringCommand {
    public let info = CommandInfo(
        category: .feed,
        shortDescription: "Fetches xkcd comics",
        longDescription: "Fetches an xkcd comic",
        helpText: "Syntax: [comic id | 'random']?",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        let comicPromise: Promise<XkcdComic, Error>

        if input == "random" {
            comicPromise = XkcdQuery().fetchRandom()
        } else {
            comicPromise = XkcdQuery().fetch(comicId: Int(input))
        }

        comicPromise.listen {
            do {
                let comic = try $0.get()
                output.append(Embed(
                    title: "xkcd #\(comic.num): \(comic.title ?? "no title")",
                    url: URL(string: "https://xkcd.com/\(comic.num)")!,
                    image: comic.img.flatMap(URL.init(string:)).map(Embed.Image.init(url:)),
                    footer: comic.alt.map { Embed.Footer(text: $0) }
                ))
            } catch {
                output.append(error, errorText: "An error occurred while fetching the comic")
            }
        }
    }
}
