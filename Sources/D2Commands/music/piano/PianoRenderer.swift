import D2Graphics
import D2Utils

struct PianoRenderer: ScaleRenderer {
    private let whiteKeyWidth: Int
    private let blackKeyWidth: Int
    private let whiteKeyHeight: Int
    private let blackKeyHeight: Int
    private let range: Range<Note>

    init(
        whiteKeyWidth: Int = 20,
        blackKeyWidth: Int = 20,
        whiteKeyHeight: Int = 100,
        blackKeyHeight: Int = 80,
        range: Range<Note>
    ) {
        self.whiteKeyWidth = whiteKeyWidth
        self.blackKeyWidth = blackKeyWidth
        self.whiteKeyHeight = whiteKeyHeight
        self.blackKeyHeight = blackKeyHeight
        self.range = range
    }

	func render(scale: Scale) throws -> Image {
        let width = whiteKeyWidth * range.count(forWhich: { $0.accidental == .none })
        let image = try Image(width: width, height: whiteKeyHeight)
        var graphics = CairoGraphics(fromImage: image)
        var x = 0

        for note in range {
            if note.accidental == .none {
                graphics.draw(Rectangle(fromX: Double(x), y: 0, width: Double(whiteKeyWidth), height: Double(whiteKeyHeight), color: Colors.white, isFilled: true))
                x += whiteKeyWidth
            } else {
                graphics.draw(Rectangle(fromX: Double(x - (blackKeyWidth / 2)), y: 0, width: Double(blackKeyWidth), height: Double(blackKeyHeight), color: Colors.black, isFilled: true))
            }
        }

        return image
    }
}
