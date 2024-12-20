import D2MessageIO
import D2NetAPIs

public class IMDBCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Searches the IMDB for movies and shows",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter a query!")
            return
        }

        do {
            let results = try await IMDBQuery(query: input).perform()
            let entries = results.entries

            await output.append(Embed(
                title: ":film_frames: IMDB Results",
                thumbnail: (entries.first?.info?.imageUrl).map(Embed.Thumbnail.init(url:)),
                color: 0xf7c936,
                fields: entries
                    .prefix(5)
                    .map { self.embedFieldOf(entry: $0) }
            ))
        } catch {
            await output.append(error, errorText: "Could not query IMDB")
        }
    }

    private func embedFieldOf(entry: IMDBResults.Entry) -> Embed.Field {
        Embed.Field(
            name: [entry.title, entry.year.map { "(\($0))" }].compactMap { $0 }.joined(separator: " "),
            value: [entry.type, entry.summary].compactMap { $0 }.joined(separator: ", ").nilIfEmpty ?? "_no info_"
        )
    }
}
