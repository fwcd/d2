import PNG
import Foundation

public struct ClosureDataDestination: DataDestination {
	private let sink: ([UInt8]) -> Void
	
	public init(sink: @escaping ([UInt8]) -> Void) {
		self.sink = sink
	}
	
	public mutating func write(_ buffer: [UInt8]) -> Void? {
		sink(buffer)
		return ()
	}
}
