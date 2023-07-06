import Foundation
import Socket
import Utils

public struct UDPPacket {
    private let data: Data

    public init?(utf8String: String) {
        if let data = utf8String.data(using: .utf8) {
            self.init(data: data)
        } else {
            return nil
        }
    }

    public init(data: Data) {
        self.data = data
    }

    public func sendTo(host: String, port: Int32) throws {
        let socket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
        guard let address = Socket.createAddress(for: host, on: port) else { throw NetworkError.invalidAddress(host, port) }
        try socket.write(from: data, to: address)
        socket.close()
    }
}
