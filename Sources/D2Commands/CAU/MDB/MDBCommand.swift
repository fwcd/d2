import Foundation
import Logging
import D2MessageIO
import Utils
import D2NetAPIs

private let log = Logger(label: "D2Commands.MDBCommand")

public class MDBCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Queries the MDB",
        longDescription: "Queries the Computer Science module database from the CAU",
        presented: true,
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            let query = try MDBQuery(moduleCode: input.nilIfEmpty)
            let result = try await query.perform()
            if let module = result.first {
                let converter = DocumentToMarkdownConverter()
                let embed = try Embed(
                    title: module.nameEnglish,
                    description: module.summary,
                    url: module.url.flatMap(URL.init(string:)),
                    fields: [
                        Embed.Field(name: "Person", value: module.person ?? "?", inline: true),
                        Embed.Field(name: "ECTS", value: "\(module.ects ?? 0)", inline: true),
                        Embed.Field(name: "Workload", value: module.workload ?? "?", inline: true),
                        Embed.Field(name: "Language", value: module.teachingLanguage ?? "?", inline: true),
                        Embed.Field(name: "Presence", value: module.presence ?? "?", inline: true),
                        Embed.Field(name: "Cycle", value: module.cycle ?? "", inline: true),
                        Embed.Field(name: "Duration", value: "\(module.duration ?? 0)", inline: true),
                        Embed.Field(name: "Prerequisites", value: module.prerequisites.map { try converter.convert(htmlFragment: $0) } ?? "_none_"),
                        Embed.Field(name: "Summary", value: module.summary.map { try converter.convert(htmlFragment: $0) } ?? "_none_"),
                        Embed.Field(name: "Contents", value: module.contents.map { try converter.convert(htmlFragment: $0) } ?? "_none_"),
                        Embed.Field(name: "Objectives", value: module.objectives.map { try converter.convert(htmlFragment: $0) } ?? "_none_")
                    ]
                )

                await output.append(embed)
            } else {
                await output.append(errorText: "No such module found")
            }
        } catch {
            await output.append(error, errorText: "An error occurred while querying.")
        }
    }
}
