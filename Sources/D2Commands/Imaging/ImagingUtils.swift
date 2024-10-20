@preconcurrency import CairoGraphics
import Utils
import Logging

private let log = Logger(label: "D2Commands.ImagingUtils")

func findBoundingBox(in image: CairoImage, where predicate: (Color) -> Bool) -> (Vec2<Int>, Vec2<Int>) {
    var topLeft = image.size
    var bottomRight = Vec2<Int>(both: 0)

    for y in 0..<image.height {
        for x in 0..<image.width {
            let pixel = image[y, x]
            if predicate(pixel) {
                topLeft = Vec2(x: min(x, topLeft.x), y: min(y, topLeft.y))
                bottomRight = Vec2(x: max(x, bottomRight.x), y: max(y, bottomRight.y))
            }
        }
    }

    log.info("Found bounding box in image at (\(topLeft), \(bottomRight))")

    if bottomRight.x < topLeft.x || bottomRight.y < topLeft.y {
        return (Vec2(both: 0), image.size)
    } else {
        return (topLeft, bottomRight)
    }
}

func colorToAlpha(in image: CairoImage, color: Color, squaredThreshold: Double = 0.01) throws -> CairoImage {
    let output = try CairoImage(width: image.width, height: image.height)

    for y in 0..<image.height {
        for x in 0..<image.width {
            let pixel = image[y, x]
            if pixel.euclideanDistance(to: color) < squaredThreshold {
                output[y, x] = .transparent
            } else {
                output[y, x] = pixel
            }
        }
    }

    return output
}

func composeImage(from template: CairoImage, with image: CairoImage, between topLeft: Vec2<Int>, and bottomRight: Vec2<Int>) throws -> CairoImage {
    let composition = try CairoImage(width: template.width, height: template.height)
    let graphics = CairoContext(image: composition)

    graphics.draw(image: image, at: topLeft.asDouble, withSize: bottomRight - topLeft)
    graphics.draw(image: template)

    return composition
}
