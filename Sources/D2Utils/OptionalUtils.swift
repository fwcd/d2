public extension Optional {
    func filter(_ predicate: (Wrapped) throws -> Bool) rethrows -> Wrapped? {
        try flatMap { try predicate($0) ? $0 : nil }
    }
}

public extension Result {
    static func from(_ value: Success?, errorIfNil: Failure) -> Self {
        value.map { Result.success($0) } ?? Result.failure(errorIfNil)
    }
}
