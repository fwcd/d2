import PNG
import Foundation

struct FoundationDataSource: DataSource {
	let data: Foundation.Data
	var index: Data.Index
	
	init(data: Foundation.Data) {
		self.data = data
		index = data.startIndex
	}
	
	mutating func read(count: Int) -> [UInt8]? {
		guard (index + count) <= data.endIndex else { return nil }
		let bytes = Array(data[index..<(index + count)])
		index += count
		return bytes
	}
}
