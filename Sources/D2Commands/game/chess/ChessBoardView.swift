import D2Utils
import D2Graphics

struct ChessBoardView {
	let image: Image?
	
	init(model: ChessBoardModel) {
		do {
			let fieldSize = 30.0
			let padding = 20.0
			let intSize = Vec2<Int>(x: (Int(fieldSize) * model.files) + (Int(padding) * 2), y: (Int(fieldSize) * model.ranks) + (Int(padding) * 2))
			let img = try Image(fromSize: intSize)
			var graphics = CairoGraphics(fromImage: img)
			
			for row in 0..<model.ranks {
				for col in 0..<model.files {
					let blackField = (col % 2 == ((row % 2 == 0) ? 0 : 1))
					let color = blackField ? Color(rgb: 0xaf4d11) : Color(rgb: 0xfad8aa)
					let x = (Double(col) * fieldSize) + padding
					let y = (Double(row) * fieldSize) + padding
					graphics.draw(Rectangle(fromX: x, y: y, width: fieldSize, height: fieldSize, color: color))
				}
			}
			
			image = img
		} catch {
			print("Error while creating chess board image")
			image = nil
		}
	}
}
