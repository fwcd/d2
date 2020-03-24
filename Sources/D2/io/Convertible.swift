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
		return [Key.MessageIOType: Value.MessageIOType](uniqueKeysWithValues: map { ($0.usingMessageIO, $1.usingMessageIO) })
	}
}

extension Dictionary: DiscordAPIConvertible where Key: DiscordAPIConvertible, Value: DiscordAPIConvertible, Key.DiscordAPIType: Hashable {
	public var usingDiscordAPI: [Key.DiscordAPIType: Value.DiscordAPIType] {
		return [Key.DiscordAPIType: Value.DiscordAPIType](uniqueKeysWithValues: map { ($0.usingDiscordAPI, $1.usingDiscordAPI) })
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
