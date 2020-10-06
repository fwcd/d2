import D2MessageIO
import Foundation
import Logging
import D2Permissions
import D2NetAPIs
import Graphics
import Utils

fileprivate let log = Logger(label: "D2Commands.WolframAlphaCommand")
fileprivate let flagPattern = try! Regex(from: "--(\\S+)")

public class WolframAlphaCommand: StringCommand {
    public let info = CommandInfo(
        category: .dictionary,
        shortDescription: "Queries Wolfram Alpha",
        longDescription: "Sets the permission level of one or more users",
        helpText: "[--image]? [--steps]? [query input]",
        requiredPermissionLevel: .vip
    )
    private var isRunning = false

    public init() {}

    public func invoke(with input: String, output: CommandOutput, context: CommandContext) {
        guard !isRunning else {
            output.append(errorText: "Wait for the first input to finish!")
            return
        }
        isRunning = true

        do {
            let flags = Set(flagPattern.allGroups(in: input).map { $0[1] })
            let processedInput = flagPattern.replace(in: input, with: "")

            if flags.contains("image") {
                // Performs a "simple" query and outputs a static image
                try performSimpleQuery(input: processedInput, output: output)
            } else {
                // Performs a full query and outputs an embed
                try performFullQuery(input: processedInput, output: output, showSteps: flags.contains("steps"))
            }
        } catch {
            output.append(error)
        }
    }

    private func performSimpleQuery(input: String, output: CommandOutput) throws {
        let query = try WolframAlphaQuery(input: input, endpoint: .simpleQuery)
        query.start().listen {
            do {
                let data = try $0.get()
                output.append(.files([Message.FileUpload(data: data, filename: "wolframalpha.png", mimeType: "image/png")]))
            } catch {
                output.append(error, errorText: "An error occurred while querying WolframAlpha.")
            }
            self.isRunning = false
        }
    }

    private func performFullQuery(input: String, output: CommandOutput, showSteps: Bool = false) throws {
        let query = try WolframAlphaQuery(input: input, endpoint: .fullQuery, showSteps: showSteps)
        query.startAndParse().listen {
            do {
                let result = try $0.get()
                let images = result.pods.flatMap { pod in pod.subpods.compactMap { self.extractImageURL(from: $0) } }
                let plot = result.pods.filter { $0.title?.lowercased().contains("plot") ?? false }.first?.subpods.first.flatMap { self.extractImageURL(from: $0) }

                output.append(Embed(
                    title: "Query Output",
                    author: Embed.Author(name: "WolframAlpha"),
                    image: (plot ?? images.last).map { Embed.Image(url: $0) },
                    thumbnail: images.first.map { Embed.Thumbnail(url: $0) },
                    color: 0xfdc81a,
                    footer: Embed.Footer(text: "success: \(result.success.map { String($0) } ?? "?"), error: \(result.error.map { String($0) } ?? "?"), timing: \(result.timing.map { String($0) } ?? "?")"),
                    fields: result.pods.map { pod in Embed.Field(
                        // TODO: Investigate why Discord sends 400s for certain queries
                        name: pod.title?.nilIfEmpty?.truncated(to: 50, appending: "...") ?? "Untitled pod",
                        value: pod.subpods.map { "\($0.title?.nilIfEmpty.map { "**\($0)** " } ?? "")\($0.plaintext ?? "")" }.joined(separator: "\n").truncated(to: 1000, appending: "...")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .nilIfEmpty
                            ?? "No content"
                    ) }.truncated(to: 6)
                ))
            } catch {
                output.append(error, errorText: "An error occurred while querying WolframAlpha.")
            }
            self.isRunning = false
        }
    }

    private func extractImageURL(from subpod: WolframAlphaSubpod) -> URL? {
        return (subpod.img?.src).flatMap { URL(string: $0) }
    }
}
