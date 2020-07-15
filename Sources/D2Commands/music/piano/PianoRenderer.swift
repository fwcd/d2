import D2Graphics
import D2Utils

struct PianoRenderer: ScaleRenderer {
    private let whiteKeyWidth: Int
    private let blackKeyWidth: Int
    private let whiteKeyPadding: Int
    private let whiteKeyHeight: Int
    private let blackKeyHeight: Int
    private let range: Range<Note>

    init(
        whiteKeyWidth: Int = 20,
        blackKeyWidth: Int = 15,
        whiteKeyPadding: Int = 2,
        whiteKeyHeight: Int = 80,
        blackKeyHeight: Int = 60,
        range: Range<Note>
    ) {
        self.whiteKeyWidth = whiteKeyWidth
        self.blackKeyWidth = blackKeyWidth
        self.whiteKeyPadding = whiteKeyPadding
        self.whiteKeyHeight = whiteKeyHeight
        self.blackKeyHeight = blackKeyHeight
        self.range = range
    }

	func render(scale: Scale) throws -> Image {
        let whiteKeyCount = range.count(forWhich: { $0.accidental == .none })
        let width = whiteKeyWidth * whiteKeyCount + whiteKeyPadding * (whiteKeyCount - 1)
        let image = try Image(width: width, height: whiteKeyHeight)
        var graphics = CairoGraphics(fromImage: image)
        var whiteKeys = [Rectangle<Double>]()
        var blackKeys = [Rectangle<Double>]()
        var x = 0

        for note in range {
            if note.accidental == .none {
                whiteKeys.append(Rectangle(fromX: Double(x), y: 0, width: Double(whiteKeyWidth), height: Double(whiteKeyHeight), color: Colors.white, isFilled: true))
                x += whiteKeyWidth + whiteKeyPadding
            } else {
                blackKeys.append(Rectangle(fromX: Double(x - (blackKeyWidth / 2)), y: 0, width: Double(blackKeyWidth), height: Double(blackKeyHeight), color: Colors.black, isFilled: true))
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
