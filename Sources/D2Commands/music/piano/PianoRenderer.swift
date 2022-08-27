import Graphics
import Utils

struct PianoRenderer: ScaleRenderer {
    private let whiteKeyWidth: Int
    private let blackKeyWidth: Int
    private let whiteKeyPadding: Int
    private let whiteKeyHeight: Int
    private let blackKeyHeight: Int
    private let lowerBound: Note
    private let upperBound: Note

    private var notes: [Note] {
        var note: Note = lowerBound
        var notes: [Note] = []
        while note.semitone < upperBound.semitone {
            notes.append(note)
            note = note.advanced(by: 1)
        }
        return notes
    }

    init(
        whiteKeyWidth: Int = 20,
        blackKeyWidth: Int = 15,
        whiteKeyPadding: Int = 2,
        whiteKeyHeight: Int = 80,
        blackKeyHeight: Int = 60,
        lowerBound: Note,
        upperBound: Note
    ) {
        self.whiteKeyWidth = whiteKeyWidth
        self.blackKeyWidth = blackKeyWidth
        self.whiteKeyPadding = whiteKeyPadding
        self.whiteKeyHeight = whiteKeyHeight
        self.blackKeyHeight = blackKeyHeight
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    func render(scale: Scale) throws -> Image {
        let scaleSemitones = Set(scale.notes.map(\.semitone))

        let notes = self.notes
        let whiteKeyCount = notes.count(forWhich: { $0.accidental == .none })
        let width = whiteKeyWidth * whiteKeyCount + whiteKeyPadding * (whiteKeyCount - 1)
        let image = try Image(width: width, height: whiteKeyHeight)
        let graphics = CairoGraphics(fromImage: image)
        var whiteKeys = [Rectangle<Double>]()
        var blackKeys = [Rectangle<Double>]()
        var x = 0

        for note in notes {
            let isWhite = note.accidental == .none
            var rectangle: Rectangle<Double>

            if isWhite {
                rectangle = Rectangle(fromX: Double(x), y: 0, width: Double(whiteKeyWidth), height: Double(whiteKeyHeight), color: Colors.white, isFilled: true)
                x += whiteKeyWidth + whiteKeyPadding
            } else {
                rectangle = Rectangle(fromX: Double(x - (blackKeyWidth / 2)), y: 0, width: Double(blackKeyWidth), height: Double(blackKeyHeight), color: Colors.black, isFilled: true)
            }

            if scaleSemitones.contains(note.semitone) {
                rectangle.color = Colors.cyan.with(alpha: 128).alphaBlend(over: rectangle.color)
            }

            if isWhite {
                whiteKeys.append(rectangle)
            } else {
                blackKeys.append(rectangle)
            }
        }

        // Make sure that the black keys are visually "on top" of the white keys

        for whiteKey in whiteKeys {
            graphics.draw(whiteKey)
        }

        for blackKey in blackKeys {
            graphics.draw(blackKey)
        }

        return image
    }
}
