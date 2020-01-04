import Logging
import SwiftDiscord
import D2Utils
import D2Graphics
import Foundation

fileprivate let log = Logger(label: "MandelbrotCommand")

public class MandelbrotCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "The mandelbrot set",
        longDescription: "Renders an image of the mandelbrot set",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .image
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let width = 400
            let height = 300
            var image = try Image(width: width, height: height)

            let time = Int(Date().timeIntervalSince1970 * 10) % 256
            let userId = Int(context.author.id.rawValue) % 100
            let paletteHash = (time * userId) / 512

            for y in 0..<height {
                for x in 0..<width {
                    let c = 0.01 * Complex(Double(x - (width / 2)), i: Double(y - (height / 2)))
                    image[y, x] = color(at: c, paletteHash: paletteHash)
                }
            }
            
            try output.append(image)
        } catch {
            log.error("\(error)")
            output.append("Could not create image")
        }
    }
    
    public func color(at c: Complex, paletteHash: Int) -> Color {
        let v = convergence(at: c)
        let step = (2 - paletteHash % 3)
        return Color(red: UInt8((v * paletteHash * step) % 256), green: UInt8((v * paletteHash * (step + 1)) % 256), blue: UInt8((v * paletteHash * (step + 2)) % 256))
    }
    
    /** Tests how many iterations it takes to reach the bound (or returns iterations if it does not). */
    private func convergence(at c: Complex, iterations: Int = 16, boundSquared: Double = 1_000_000.0) -> Int {
        var value: Complex = 0

        for i in 0..<iterations {
            guard value.magnitudeSquared < boundSquared else { return i }
            value = value.squared + c
        }

        return iterations
    }
}
