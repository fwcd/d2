import D2Graphics

public struct UnoCard: Hashable {
	public let color: UnoColor
	public let label: UnoCardLabel
	public var image: Image? { return createImage() }
	
	private func createImage() -> Image? {
		do {
			let img = try Image(width: 100, height: 300)
			var graphics = CairoGraphics(fromImage: img)
			
			// TODO
			return img
		} catch {
			print("Error while creating uno card image: \(error)")
			return nil
		}
	}
}
