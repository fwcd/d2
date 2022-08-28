import Graphics
import Utils
import MusicTheory

struct FretboardChordRenderer: ChordRenderer {
    private let width: Int
    private let height: Int
    private let gutterHeight: Double
    private let padding: Double
    private let fgColor: Color
    private let fretboard: Fretboard
    private let minFrets: Int

    init(
        width: Int = 150,
        height: Int = 200,
        gutterHeight: Double = 10,
        padding: Double = 20,
        fgColor: Color = Colors.white,
        fretboard: Fretboard = Fretboard(),
        minFrets: Int = 7
    ) {
        self.width = width
        self.height = height
        self.gutterHeight = gutterHeight
        self.padding = padding
        self.fgColor = fgColor
        self.fretboard = fretboard
        self.minFrets = minFrets
    }

    func render(chord: Chord) throws -> Image {
        let image = try Image(width: width, height: height)
        let graphics = CairoGraphics(fromImage: image)
        let guitarChord = try FretboardChord(from: chord, on: fretboard)
        let fretCount = max(minFrets, guitarChord.maxFret + 1)
        let stringCount = fretboard.stringCount

        let innerWidth = Double(width) - (padding * 2)
        let innerHeight = (Double(height) - (padding * 2)) - gutterHeight
        let stringSpacing = innerWidth / Double(stringCount - 1)
        let fretSpacing = innerHeight / Double(fretCount - 1)
        let dotRadius = fretSpacing * 0.4
        let topLeft = Vec2(x: padding, y: padding + gutterHeight)

        graphics.draw(Rectangle(topLeft: topLeft - Vec2(y: gutterHeight), size: Vec2(x: innerWidth, y: gutterHeight), color: fgColor, isFilled: true))

        for stringIndex in 0..<stringCount {
            let position = topLeft + Vec2(x: stringSpacing * Double(stringIndex))
            graphics.draw(LineSegment(from: position, to: position + Vec2(y: innerHeight), color: fgColor))
        }

        for fretIndex in 0..<fretCount {
            let position = topLeft + Vec2(y: fretSpacing * Double(fretIndex))
            graphics.draw(LineSegment(from: position, to: position + Vec2(x: innerWidth), color: fgColor))
        }

        for dot in guitarChord.dots {
            let dotX = Double(dot.guitarString) * stringSpacing
            if dot.fret > 0 {
                let position = topLeft + Vec2(x: dotX, y: (Double(dot.fret - 1) + 0.5) * fretSpacing)
                graphics.draw(Ellipse(center: position, radius: Vec2(both: dotRadius), color: fgColor))
            } else {
                let position = topLeft + Vec2(x: dotX, y: -gutterHeight - dotRadius)
                graphics.draw(Ellipse(center: position, radius: Vec2(both: dotRadius), color: fgColor, isFilled: false))
            }
        }

        return image
    }
}
