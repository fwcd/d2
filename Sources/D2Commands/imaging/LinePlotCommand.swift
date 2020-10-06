import Graphics
import SwiftPlot
import AGGRenderer

public class LinePlotCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Plots a 2-column table as a line graph",
        longDescription: "Plots a 2-column table as a line graph where the first column represents the x-axis and the second column the y-axis",
        requiredPermissionLevel: .basic
    )

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let table = input.asTable, table.first?.count == 2 else {
            output.append(errorText: "Can only plot non-empty 2-column tables!")
            return
        }

        // let renderer = AGGRenderer()
        // let graph = LineGraph<String, String>(enablePrimaryAxisGrid: true)
        // graph.addSeries(table[0], table[1])
    }
}
