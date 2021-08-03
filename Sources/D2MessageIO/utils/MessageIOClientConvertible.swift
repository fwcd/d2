public protocol MessageIOClientConvertible {
    associatedtype MessageIOType

    func usingMessageIO(with client: MessageClient) -> MessageIOType
}
