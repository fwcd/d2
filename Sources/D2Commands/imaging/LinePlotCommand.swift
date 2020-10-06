import Foundation
import Utils
import Graphics
import SwiftPlot
import AGGRenderer

public class LinePlotCommand: Command {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "Plots a 2-column NDArray as a line graph",
        longDescription: "Plots a 2-column NDArray as a line graph where the first column represents the x-axis and the second column the y-axis",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard let columns = input.asNDArrays?.first?.asMatrix?.columns.map({ $0.map(\.asDouble) }), columns.count == 2 else {
            output.append(errorText: "Can only plot 2-column tables as line graph!")
            return
        }

        let renderer = AGGRenderer()
        var graph = LineGraph<Double, Double>(enablePrimaryAxisGrid: true)
        graph.addSeries(columns[0], columns[1], label: "Plot", color: .blue)
        graph.plotLineThickness = 3
        graph.drawGraph(renderer: renderer)

        guard let data = Data(base64Encoded: renderer.base64Png()), let image = try? Image(fromPng: data) else {
            output.append(errorText: "Could not render to valid PNG!")
            return
        }

        output.append(.image(image))
    }
}
