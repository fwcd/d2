enum Result<T> {
	case ok(T)
	case error(Error)
	
	static func wrap<R>(action: () throws -> R) -> Result<R> {
		do {
			return .ok(try action())
		} catch {
			return .error(error)
		}
	}
	
	func map<R>(mapper: (T) throws -> R) -> Result<R> {
		switch self {
			case .ok(let input):
				do {
					return .ok(try mapper(input))
				} catch let err {
					return .error(err)
				}
			case .error(let err):
				return .error(err)
		}
	}
}
