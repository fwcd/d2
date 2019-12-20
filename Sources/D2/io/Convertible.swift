public protocol DiscordAPIConvertible {
	associatedtype DiscordAPIType
	
	var usingDiscordAPI: DiscordAPIType { get }
}

public protocol MessageIOConvertible {
	associatedtype MessageIOType
	
	var usingMessageIO: MessageIOType { get }
}

extension Dictionary: MessageIOConvertible where Key: MessageIOConvertible, Value: MessageIOConvertible, Key.MessageIOType: Hashable {
	public var usingMessageIO: [Key.MessageIOType: Value.MessageIOType] {
		let entries = [(Key.MessageIOType, Value.MessageIOType)] = map { ($0.usingMessageIO, $1.usingMessageIO) }
		return Dictionary(uniqueKeysWithValues: entries)
	}
}

extension Dictionary: DiscordAPIConvertible where Key: DiscordAPIConvertible, Value: DiscordAPIConvertible, Key.DiscordAPIType: Hashable {
	public var usingDiscordAPI: [Key.DiscordAPIType: Value.DiscordAPIType] {
		let entries = [(Key.DiscordAPIType, Value.DiscordAPIType)] = map { ($0.usingDiscordAPI, $1.usingDiscordAPI) }
		return Dictionary(uniqueKeysWithValues: entries)
	}
}

extension Array: MessageIOConvertible where Element: MessageIOConvertible {
	public var usingMessageIO: [Element.MessageIOType] {
		return map { $0.usingMessageIO }
	}
}

extension Array: DiscordAPIConvertible where Element: DiscordAPIConvertible {
	public var usingDiscordAPI: [Element.DiscordAPIType] {
		return map { $0.usingDiscordAPI }
	}
}
