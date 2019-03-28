import PNG
import Foundation

public struct FoundationDataSource: DataSource {
	private let data: Foundation.Data
	private var index: Data.Index
	
	public init(data: Foundation.Data) {
		self.data = data
		index = data.startIndex
	}
	
	public mutating func read(count: Int) -> [UInt8]? {
		guard (index + count) <= data.endIndex else { return nil }
		let bytes = Array(data[index..<(index + count)])
		index += count
		return bytes
	}
}
