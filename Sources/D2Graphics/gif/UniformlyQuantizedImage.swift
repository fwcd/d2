import Foundation

/** Color channels, assuming RGB colors. */
fileprivate let CHANNELS = 3

/**
 * An image where all colors are evenly
 * spaced along each channel.
 */
public struct UniformlyQuantizedImage {
    public private(set) var colorTable: [Color]
    private let colorsPerChannel: Int
    private let colorStride: Int
    private let transparentColor: Int
    private let image: Image
    
    public init(fromImage image: Image, colorCount: Int, transparentColor: Int) {
        self.image = image
        self.transparentColor = transparentColor

        colorTable = []
        colorsPerChannel = Int(pow(Double(colorCount), Double(CHANNELS)))
        colorStride = 256 / colorsPerChannel
        
        for r in 0..<colorsPerChannel {
            for g in 0..<colorsPerChannel {
                for b in 0..<colorsPerChannel {
                    colorTable.append(Color(
                        red: UInt8(r * colorStride),
                        green: UInt8(g * colorStride),
                        blue: UInt8(b * colorStride)
                    ))
                }
            }
        }
    }
    
    private func tableIndexOf(r: Int, g: Int, b: Int) -> Int {
        return (colorsPerChannel * colorsPerChannel * r) + (colorsPerChannel * g) + b
    }
    
    private func quantize(color: Color) -> Int {
        if color.alpha < 128 {
            return transparentColor
        } else {
            let maxChannelColorIndex = colorsPerChannel - 1
            let r = min(maxChannelColorIndex, Int(color.red) / colorStride)
            let g = min(maxChannelColorIndex, Int(color.green) / colorStride)
            let b = min(maxChannelColorIndex, Int(color.blue) / colorStride)
            return tableIndexOf(r: r, g: g, b: b)
        }
    }
    
    public subscript(_ x: Int, _ y: Int) -> Int {
        return quantize(color: image[y, x])
    }
}
