import Foundation
import D2MessageIO
import D2NetAPIs
import Utils

public class LyricsCommand: StringCommand {
    public private(set) var info = CommandInfo(
        category: .music,
        shortDescription: "Fetches the lyrics of a song",
        presented: true,
        requiredPermissionLevel: .basic
    )
    private let showChords: Bool

    public init(showChords: Bool = true) {
        self.showChords = showChords

        if showChords {
            let suffix = " with chords"
            info.shortDescription += suffix
            info.longDescription += suffix
        }
    }

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        guard !input.isEmpty else {
            await output.append(errorText: "Please enter a song to search for!")
            return
        }

        // Search for the song
        do {
            let searchResults = try await UltimateGuitarQuery<UltimateGuitarSearchResults>(host: "www.ultimate-guitar.com", path: "/search.php", query: ["search_type": "title", "value": input]).perform().store.page.data
            guard let tab = searchResults.results.first(where: \.isChordTab) else {
                await output.append(errorText: "No search results found!")
                return
            }
            guard let url = tab.tabUrl.flatMap(URL.init(string:)), let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let host = urlComponents.host else {
                await output.append(errorText: "Found search result has invalid URL!")
                return
            }
            let path = urlComponents.path

            // Query the song's tab page
            do {
                let tabView = try await UltimateGuitarQuery<UltimateGuitarTabPage>(host: host, path: path, query: [:]).perform().store.page.data.tabView
                guard let wikiTab = tabView.wikiTab, let content = wikiTab.content else {
                    await output.append(errorText: "No tab markup found!")
                    return
                }
                let document = try UltimateGuitarTabParser().parse(tabMarkup: content)

                // Output the lyrics
                let embeds = document.sections.flatMap { section in
                    (self.showChords ? section.text : section.textWithoutChords)
                        .split(separator: "\n")
                        .chunks(ofLength: 6)
                        .map { Embed.Field(name: section.title.nilIfEmpty ?? "Unnamed Verse", value: """
                            ```
                            \($0.joined(separator: "\n").nilIfEmpty ?? "...")
                            ```
                            """) }
                }.chunks(ofLength: 6).enumerated().map { (i, fields) in
                    Embed(
                        title: "\(self.showChords ? "Chords" : "Lyrics") for `\(tab.songName ?? input)` by `\(tab.artistName ?? "?")` (Part \(i + 1))",
                        url: url,
                        fields: Array(fields)
                    )
                }
                await output.append(.compound(embeds.map { .embed($0) }))
            } catch {
                await output.append(error, errorText: "Could not query song tab")
            }
        } catch {
            await output.append(error, errorText: "Could not search for song")
        }
    }
}
