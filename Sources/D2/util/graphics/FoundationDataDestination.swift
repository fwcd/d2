import PNG
import Foundation

struct FoundationDataDestination: DataDestination {
	var data: Foundation.Data
	
	init(data: Foundation.Data) {
		self.data = data
	}
	
	mutating func write(_ buffer: [UInt8]) -> Void? {
		data.append(contentsOf: buffer)
		return ()
	}
}
