import Foundation

fileprivate let asciiCharacters = CharacterSet(charactersIn: " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")

extension String {
	public var asciiOnly: String? {
		return components(separatedBy: asciiCharacters).joined()
	}
	
	public var nilIfEmpty: String? {
		return isEmpty ? nil : self
	}
	
	public var isAlphabetic: Bool {
		for scalar in unicodeScalars {
			if !CharacterSet.letters.contains(scalar) {
				return false
			}
		}
		return true
	}
	
	public func truncate(_ length: Int, appending trailing: String = "") -> String {
		if count > length {
			return prefix(length) + trailing
		} else {
			return self
		}
	}
	
	public func split(by length: Int) -> [String] {
		var start = startIndex
		var output = [String]()
		
		while start < endIndex {
			let end = index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
			output.append(String(self[start..<end]))
			start = end
		}
		
		return output
	}
}
