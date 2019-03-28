import PNG
import Foundation

public struct FoundationDataDestination: DataDestination {
	public private(set) var data: Foundation.Data
	
	public init(data: Foundation.Data) {
		self.data = data
	}
	
	public mutating func write(_ buffer: [UInt8]) -> Void? {
		data.append(contentsOf: buffer)
		return ()
	}
}
