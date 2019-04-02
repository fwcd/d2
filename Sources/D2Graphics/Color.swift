public struct Color: Hashable {
	public let red: UInt8
	public let green: UInt8
	public let blue: UInt8
	public let alpha: UInt8
	
	public var rgb: UInt32 { return (UInt32(red) << 16) | (UInt32(green) << 8) | UInt32(blue) }
	public var rgba: UInt32 { return (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | UInt32(alpha) }
	public var argb: UInt32 { return (UInt32(alpha) << 24) | (UInt32(red) << 16) | (UInt32(green) << 8) | UInt32(blue) }
	
	public var asDoubleTuple: (red: Double, green: Double, blue: Double, alpha: Double) {
		return (red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
	}
	
	public init(rgb: UInt32) {
		red = UInt8((rgb >> 16) & 0xFF)
		green = UInt8((rgb >> 8) & 0xFF)
		blue = UInt8(rgb & 0xFF)
		alpha = 255
	}
	
	public init(rgba: UInt32) {
		red = UInt8((rgba >> 24) & 0xFF)
		green = UInt8((rgba >> 16) & 0xFF)
		blue = UInt8((rgba >> 8) & 0xFF)
		alpha = UInt8(rgba & 0xFF)
	}
	
	public init(argb: UInt32) {
		alpha = UInt8((argb >> 24) & 0xFF)
		red = UInt8((argb >> 16) & 0xFF)
		green = UInt8((argb >> 8) & 0xFF)
		blue = UInt8(argb & 0xFF)
	}
	
	public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
		self.red = red
		self.green = green
		self.blue = blue
		self.alpha = alpha
	}
	
	public func with(alpha newAlpha: UInt8) -> Color {
		return Color(red: red, green: green, blue: blue, alpha: newAlpha)
	}
	
	public func alphaBlend(over bottomLayer: Color) -> Color {
		let floatAlpha = Double(alpha) / 255.0
		let invAlpha = 1.0 - floatAlpha
		return Color(
			red: UInt8((Double(red) * floatAlpha) + (Double(bottomLayer.red) * invAlpha)),
			green: UInt8((Double(green) * floatAlpha) + (Double(bottomLayer.green) * invAlpha)),
			blue: UInt8((Double(blue) * floatAlpha) + Double(bottomLayer.blue) * invAlpha
)		)
	}
}
