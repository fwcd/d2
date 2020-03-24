import Logging
import D2Utils
import D2Graphics

fileprivate let log = Logger(label: "ChessBoardView")

struct ChessBoardView {
	let image: Image?
	
	init(model: ChessBoardModel) {
		do {
			let theme = ChessTheme.defaultTheme
			let fieldSize = 30.0
			let halfFieldSize = fieldSize / 2
			let padding = 20.0
			let intBoardSize = Vec2<Int>(x: Int(fieldSize) * model.files, y: Int(fieldSize) * model.ranks)
			let intSize = Vec2<Int>(x: intBoardSize.x + (Int(padding) * 2), y: intBoardSize.y + (Int(padding) * 2))
			
			let fontSize = 12.0
			let halfFontSize = fontSize / 2
			let leftTextX = 5.0
			let topTextY = 10.0
			let rightTextX = Double(intBoardSize.x) + padding + leftTextX
			let bottomTextY = Double(intBoardSize.y) + padding + topTextY + (fontSize / 2)
			
			let img = try Image(fromSize: intSize)
			var graphics = CairoGraphics(fromImage: img)
			
			for row in 0..<model.ranks {
				let y = (Double(row) * fieldSize) + padding
				let textY = y + halfFieldSize + halfFontSize
				let letter = String(rankOf(y: row))
				
				graphics.draw(Text(letter, withSize: fontSize, at: Vec2(x: leftTextX, y: textY)))
				graphics.draw(Text(letter, withSize: fontSize, at: Vec2(x: rightTextX, y: textY)))
				
				for col in 0..<model.files {
					let whiteField = (col % 2 == ((row % 2 == 0) ? 0 : 1))
					let color = whiteField ? theme.lightColor : theme.darkColor
					let x = (Double(col) * fieldSize) + padding
					
					graphics.draw(Rectangle(fromX: x, y: y, width: fieldSize, height: fieldSize, color: color))
					
					if let piece = model[Vec2(x: col, y: row)] {
						graphics.draw(try Image(fromPngFile: piece.resourcePng), at: Vec2(x: x, y: y), withSize: Vec2(x: Int(fieldSize), y: Int(fieldSize)))
					}
				}
			}
			
			for col in 0..<model.files {
				let x = (Double(col) * fieldSize) + padding
				let textX = (x + halfFieldSize) - halfFontSize
				let letter = String(fileOf(x: col) ?? "?").uppercased()
				
				graphics.draw(Text(letter, withSize: fontSize, at: Vec2(x: textX, y: topTextY)))
				graphics.draw(Text(letter, withSize: fontSize, at: Vec2(x: textX, y: bottomTextY)))
			}
			
			image = img
		} catch {
			log.warning("Error while creating chess board image: \(error)")
			image = nil
		}
	}
}
