import Utils
@preconcurrency import CairoGraphics

func convolve(pixels: [[Color]], with filterMatrix: Matrix<Double>) async -> [[Color]] {
    let height = pixels.count
    let width = pixels[0].count
    let halfMatrixWidth = filterMatrix.width / 2
    let halfMatrixHeight = filterMatrix.height / 2

    var result = [[Color]]()

    func clampToByte(_ value: Double) -> UInt8 {
        UInt8(max(0, min(255, value)))
    }

    // Perform the convolution
    for y in 0..<height {
        var row = [Color]()

        for x in 0..<width {
            var value: (red: Double, green: Double, blue: Double, alpha: Double) = (red: 0, green: 0, blue: 0, alpha: 0)
            for dy in 0..<filterMatrix.height {
                for dx in 0..<filterMatrix.width {
                    let pixel = pixels[max(0, min(height - 1, y + dy - halfMatrixHeight))][max(0, min(width - 1, x + dx - halfMatrixWidth))]
                    let factor = filterMatrix[dy, dx]

                    value = (
                        red: value.red + Double(pixel.red) * factor,
                        green: value.green + Double(pixel.green) * factor,
                        blue: value.blue + Double(pixel.blue) * factor,
                        alpha: value.alpha + Double(pixel.alpha) * factor
                    )
                }
            }

            row.append(Color(
                red: clampToByte(value.red),
                green: clampToByte(value.green),
                blue: clampToByte(value.blue),
                alpha: max(pixels[y][x].alpha, clampToByte(value.alpha))
            ))
        }

        await Task.yield()

        result.append(row)
    }

    return result
}
