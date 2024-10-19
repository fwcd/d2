public protocol MessageIOClientConvertible {
    associatedtype MessageIOType

    func usingMessageIO(with sink: any Sink) async -> MessageIOType
}
