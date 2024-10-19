import Logging
import Utils
@preconcurrency import CairoGraphics

fileprivate let log = Logger(label: "D2Commands.ChessBoardView")

struct ChessBoardView {
    let image: CairoImage?

    init(model: ChessBoardModel) {
        do {
            let theme = ChessTheme.defaultTheme
            let fieldSize = 30.0
            let halfFieldSize = fieldSize / 2
            let padding = 20.0
            let intBoardSize = Vec2<Int>(x: Int(fieldSize) * ChessBoardModel.files, y: Int(fieldSize) * ChessBoardModel.ranks)
            let intSize = Vec2<Int>(x: intBoardSize.x + (Int(padding) * 2), y: intBoardSize.y + (Int(padding) * 2))

            let fontSize = 12.0
            let halfFontSize = fontSize / 2
            let leftTextX = 5.0
            let topTextY = 10.0
            let rightTextX = Double(intBoardSize.x) + padding + leftTextX
            let bottomTextY = Double(intBoardSize.y) + padding + topTextY + (fontSize / 2)

            let img = try CairoImage(size: intSize)
            let graphics = CairoContext(image: img)

            for row in 0..<ChessBoardModel.ranks {
                let y = (Double(row) * fieldSize) + padding
                let textY = y + halfFieldSize + halfFontSize
                let letter = String(rankOf(y: row))

                graphics.draw(text: Text(letter, withSize: fontSize, at: Vec2(x: leftTextX, y: textY)))
                graphics.draw(text: Text(letter, withSize: fontSize, at: Vec2(x: rightTextX, y: textY)))

                for col in 0..<ChessBoardModel.files {
                    let whiteField = (col % 2 == ((row % 2 == 0) ? 0 : 1))
                    let color = whiteField ? theme.lightColor : theme.darkColor
                    let x = (Double(col) * fieldSize) + padding

                    graphics.draw(rect: Rectangle(fromX: x, y: y, width: fieldSize, height: fieldSize, color: color))

                    if let piece = model[Vec2(x: col, y: row)] {
                        graphics.draw(image: try CairoImage(pngFilePath: piece.resourcePng), at: Vec2(x: x, y: y), withSize: Vec2(x: Int(fieldSize), y: Int(fieldSize)))
                    }
                }
            }

            for col in 0..<ChessBoardModel.files {
                let x = (Double(col) * fieldSize) + padding
                let textX = (x + halfFieldSize) - halfFontSize
                let letter = String(fileOf(x: col) ?? "?").uppercased()

                graphics.draw(text: Text(letter, withSize: fontSize, at: Vec2(x: textX, y: topTextY)))
                graphics.draw(text: Text(letter, withSize: fontSize, at: Vec2(x: textX, y: bottomTextY)))
            }

            image = img
        } catch {
            log.warning("Error while creating chess board image: \(error)")
            image = nil
        }
    }
}
