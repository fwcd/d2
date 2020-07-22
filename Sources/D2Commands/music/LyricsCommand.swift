import Foundation
import D2MessageIO
import D2NetAPIs

public class LyricsCommand: StringCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Fetches the lyrics of a song",
        requiredPermissionLevel: .basic
    )
    private let showChords: Bool

    public init(showChords: Bool = true) {
        self.showChords = showChords
    }

    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        guard !input.isEmpty else {
            output.append(errorText: "Please enter a song to search for!")
            return
        }

        // Search for the song
        UltimateGuitarQuery<UltimateGuitarSearchResults>(host: "www.ultimate-guitar.com", path: "/search.php", query: ["search_type": "title", "value": input]).perform {
            do {
                let searchResults = try $0.get().store.page.data
                guard let tab = searchResults.results.first(where: \.isChordTab) else {
                    output.append(errorText: "No search results found!")
                    return
                }
                guard let url = tab.tabUrl.flatMap(URL.init(string:)), let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                    let host = urlComponents.host else {
                    output.append(errorText: "Found search result has invalid URL!")
                    return
                }
                let path = urlComponents.path

                // Query the song's tab page
                UltimateGuitarQuery<UltimateGuitarTabPage>(host: host, path: path, query: [:]).perform {
                    do {
                        let tabView = try $0.get().store.page.data.tabView
                        guard let wikiTab = tabView.wikiTab, let content = wikiTab.content else {
                            output.append(errorText: "No tab markup found!")
                            return
                        }
                        let document = try UltimateGuitarTabParser().parse(tabMarkup: content)

                        // Output the lyrics
                        output.append(Embed(
                            title: "Lyrics for `\(tab.songName ?? input)` by `\(tab.artistName ?? "?")`",
                            fields: document.sections.map {
                                Embed.Field(name: $0.title.nilIfEmpty ?? "Unnamed Verse", value: """
                                    ```
                                    \(self.showChords ? $0.text : $0.textWithoutChords)
                                    ```
                                    """)
                            }
                        ))
                    } catch {
                        output.append(error, errorText: "Could not query song tab")
                    }
                }
            } catch {
                output.append(error, errorText: "Could not search for song")
            }
        }
    }
}
