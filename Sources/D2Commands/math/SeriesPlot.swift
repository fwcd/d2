import SwiftPlot

public protocol SeriesPlot: Plot {
    static func createDefault() -> Self

    mutating func addSeries(_ xs: [Double], _ ys: [Double], label: String, color: Color)
}

extension LineGraph: SeriesPlot where T == Double, U == Double {
    public static func createDefault() -> Self {
        var plot = Self(enablePrimaryAxisGrid: true)
        plot.plotLineThickness = 3
        return plot
    }

    public mutating func addSeries(_ xs: [Double], _ ys: [Double], label: String, color: Color) {
        addSeries(xs, ys, label: label, color: color, axisType: .primaryAxis)
    }
}

extension BarGraph: SeriesPlot where T == Double, U == Double {
    public static func createDefault() -> Self {
        Self(enableGrid: true)
    }

    public mutating func addSeries(_ xs: [Double], _ ys: [Double], label: String, color: Color) {
        addSeries(xs, ys, label: label, color: color, hatchPattern: .none, graphOrientation: .vertical)
    }
}


