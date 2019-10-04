public typealias Phantom<P> = PhantomWrapped<Void, P>

public func phantom<P>() -> Phantom<P> { return Phantom(value: ()) }

/**
 * A wrapper that pretends as if it
 * owns another type `P`. Mainly useful
 * for using generically specialized functions
 * without actually accepting or returning
 * a value of the type parameter.
 */
public struct PhantomWrapped<T, P> {
    public let value: T
    
    public init(value: T) {
        self.value = value
    }
}
