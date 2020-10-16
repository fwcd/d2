import D2MessageIO
import D2NetAPIs
import Utils

public class TimeTableCommand: StringCommand {
    public let info = CommandInfo(
        category: .cau,
        shortDescription: "Generates a time table from CAU modules",
        longDescription: "Creates a time table from CAU modules by querying the module/lecture databases",
        helpText: "Syntax: [lecture 1], [lecture 2]...",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        let lectureNames = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard !lectureNames.isEmpty else {
            output.append(errorText: "Please enter one or more lecture names, separated by comma!")
            return
        }

        let resultsPromise = sequence(promises: lectureNames.map { name in {
            Promise.catching { try UnivISQuery(search: .lectures, params: [.name: name]) }.then { $0.start() }
        } })

        resultsPromise.listen {
            do {
                let lectures = try $0.get().compactMap { $0.childs.compactMap { $0 as? UnivISLecture }.first }

                output.append(.compound([
                    .embed(Embed(
                        title: ":calendar_spiral: TimeTable",
                        fields: [
                            Embed.Field(name: "Lectures", value: lectures.map { $0.name ?? "?" }.joined(separator: "\n").nilIfEmpty ?? "_none_")
                        ]
                    ))
                ]))
            } catch {
                output.append(error, errorText: "Could not query lectures from UnivIS!")
            }
        }
    }
}
