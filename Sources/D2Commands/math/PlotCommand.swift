import Foundation
import Utils
import Graphics
import SwiftPlot
import AGGRenderer

public typealias LinePlotCommand = PlotCommand<LineGraph<Double, Double>>
public typealias BarPlotCommand = PlotCommand<BarGraph<Int, Double>>

public class PlotCommand<P>: Command where P: SeriesPlot {
    public let info = CommandInfo(
        category: .math,
        shortDescription: "Plots an NDArray",
        longDescription: "Plots a 1- or 2-column NDArray where the first column represents the x-axis and the second column the y-axis",
        requiredPermissionLevel: .basic
    )
    public let inputValueType: RichValueType = .ndArrays
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(with input: RichValue, output: CommandOutput, context: CommandContext) {
        guard var columns = input.asNDArrays?.first?.asMatrix?.columns.map({ $0.map(\.asDouble) }), [1, 2].contains(columns.count) else {
            output.append(errorText: "Can only plot 1- or 2-column tables!")
            return
        }

        if columns.count == 1 {
            let indices = columns[0].indices.map(Double.init)
            columns.insert(indices, at: 0)
        }

        guard columns[0].count > 1 else {
            output.append(errorText: "2 or more data points are needed!")
            return
        }

        let renderer = AGGRenderer()
        var plot = P.createDefault()
        plot.addSeries(columns[0], columns[1], label: "Plot", color: .blue)
        plot.drawGraph(renderer: renderer)

        guard let data = Data(base64Encoded: renderer.base64Png()), let image = try? Image(fromPng: data) else {
            output.append(errorText: "Could not render to valid PNG!")
            return
        }

        output.append(.image(image))
    }
}
