public protocol DiscordAPIConvertible {
	associatedtype DiscordAPIType
	
	var usingDiscordAPI: DiscordAPIType { get }
}

public protocol MessageIOConvertible {
	associatedtype MessageIOType
	
	var usingMessageIO: MessageIOType { get }
}

extension Dictionary: MessageIOConvertible where Key: MessageIOConvertible, Value: MessageIOConvertible {
	var usingMessageIO: [Key.MessageIOType: Value.MessageIOType] {
		return Dictionary(uniqueKeysWithValues: map {
			($0.usingMessageIO, $1.usingMessageIO)
		})
	}
}

extension Dictionary: DiscordAPIConvertible where Key: DiscordAPIConvertible, Value: DiscordAPIConvertible {
	var usingDiscordAPI: [Key.DiscordAPIType: Value.DiscordAPIType] {
		return Dictionary(uniqueKeysWithValues: map {
			($0.usingDiscordAPI, $1.usingDiscordAPI)
		})
	}
}

extension Array: MessageIOConvertible where Element: MessageIOConvertible {
	var usingMessageIO: [Element.MessageIOType] {
		return map { $0.usingMessageIO }
	}
}

extension Array: DiscordAPIConvertible where Element: DiscordAPIConvertible {
	var usingMessageIO: [Element.DiscordAPIType] {
		return map { $0.usingDiscordAPI }
	}
}
