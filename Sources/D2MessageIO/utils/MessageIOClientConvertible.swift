public protocol MessageIOClientConvertible {
    associatedtype MessageIOType

    func usingMessageIO(with client: any MessageIOSink) -> MessageIOType
}
