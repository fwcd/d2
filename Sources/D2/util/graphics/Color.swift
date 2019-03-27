struct Color {
	let red: UInt8
	let green: UInt8
	let blue: UInt8
	let alpha: UInt8
	
	var rgb: UInt32 { return (red << 16) | (green << 8) | blue }
	var rgba: UInt32 { return (red << 24) | (green << 16) | (blue << 8) | alpha }
	var argb: UInt32 { return (alpha << 24) | (red << 16) | (green << 8) | blue }
	
	init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
		self.red = red
		self.green = green
		self.blue = blue
		self.alpha = alpha
	}
}
