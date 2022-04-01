import Logging
import D2MessageIO
import Utils
import Graphics
import Foundation

fileprivate let log = Logger(label: "D2Commands.MandelbrotCommand")

public class MandelbrotCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "The mandelbrot set",
        longDescription: "Renders an image of the mandelbrot set",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .image

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) {
        do {
            let width = 400
            let height = 300
            let image = try Image(width: width, height: height)

            var hasher = Hasher()
            let time = Int(Date().timeIntervalSince1970 * 10) % 256
            let userId = context.author?.id
            hasher.combine(time)
            hasher.combine(userId)
            let paletteHash = Int((hasher.finalize() % 50).magnitude)

            for y in 0..<height {
                for x in 0..<width {
                    let c = 0.01 * Complex(Double(x - (width / 2)), i: Double(y - (height / 2)))
                    image[y, x] = color(at: c, paletteHash: paletteHash)
                }
            }

            try output.append(image)
        } catch {
            output.append(error, errorText: "Could not create image")
        }
    }

    public func color(at c: Complex, paletteHash: Int) -> Color {
        let v = convergence(at: c)
        let step = (2 - paletteHash % 3)
        return Color(red: UInt8((v * paletteHash * step) % 256), green: UInt8((v * paletteHash * (step + 1)) % 256), blue: UInt8((v * paletteHash * (step + 2)) % 256))
    }

    /// Tests how many iterations it takes to reach the bound (or returns iterations if it does not).
    private func convergence(at c: Complex, iterations: Int = 16, boundSquared: Double = 1_000_000.0) -> Int {
        var value: Complex = 0

        for i in 0..<iterations {
            guard value.magnitudeSquared < boundSquared else { return i }
            value = value.squared + c
        }

        return iterations
    }
}
