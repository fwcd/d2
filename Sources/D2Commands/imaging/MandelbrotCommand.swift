import SwiftDiscord
import D2Utils
import D2Graphics

public class MandelbrotCommand: StringCommand {
    public let info = CommandInfo(
        category: .imaging,
        shortDescription: "The mandelbrot set",
        longDescription: "Renders an image of the mandelbrot set"
    )
    public let outputValueType: RichValueType = .image
    
    public init() {}
    
    public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
        do {
            let width = 400
            let height = 300
            var image = try Image(width: width, height: height)
            
            for y in 0..<height {
                for x in 0..<width {
                    let c = 0.01 * Complex(Double(x - (width / 2)), i: Double(y - (height / 2)))
                    image[y, x] = color(at: c)
                }
            }
            
            try output.append(image)
        } catch {
            print(error)
            output.append("Could not create image")
        }
    }
    
    public func color(at c: Complex) -> Color {
        let v = convergence(at: c)
        return v < 16 ? Colors.black : Colors.white
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
