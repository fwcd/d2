import Graphics
import Utils
import Logging

fileprivate let log = Logger(label: "D2Commands.ComposeImageUtils")

func findBoundingBox(in image: Image, where predicate: (Color) -> Bool) -> (Vec2<Int>, Vec2<Int>) {
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

func composeImage(from template: Image, with image: Image, between topLeft: Vec2<Int>, and bottomRight: Vec2<Int>) throws -> Image {
    let composition = try Image(width: template.width, height: template.height)
    var graphics = CairoGraphics(fromImage: composition)

    graphics.draw(image, at: topLeft.asDouble, withSize: bottomRight - topLeft)
    graphics.draw(template)

    return composition
}
