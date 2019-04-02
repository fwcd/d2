import D2Utils
import D2Graphics

struct ChessBoardView {
	let image: Image?
	
	init(model: ChessBoardModel) {
		do {
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
					let blackField = (col % 2 == ((row % 2 == 0) ? 0 : 1))
					let color = blackField ? Color(rgb: 0xaf4d11) : Color(rgb: 0xfad8aa)
					let x = (Double(col) * fieldSize) + padding
					
					graphics.draw(Rectangle(fromX: x, y: y, width: fieldSize, height: fieldSize, color: color))
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
			print("Error while creating chess board image")
			image = nil
		}
	}
}
