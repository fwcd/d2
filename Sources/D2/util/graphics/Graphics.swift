protocol Graphics {
	var color: Color { get set }
	
	func draw(_ line: LineSegment<Int>)
}
