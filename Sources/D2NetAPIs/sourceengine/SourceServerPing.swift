import Foundation
import Socket

public struct SourceServerPing {
    private let host: String
    private let port: Int32
    private let timeoutMs: UInt
    
    public init(host: String, port: Int32, timeoutMs: UInt = 0) {
        self.host = host
        self.port = port
        self.timeoutMs = timeoutMs
    }

    public func perform() throws -> SourceServerInfoResponse {
        guard let address = Socket.createAddress(for: host, on: port) else { throw SourceServerPingError.invalidAddress(host, port) }
        let socket = try Socket.create(type: .datagram, proto: .udp)

        try socket.setReadTimeout(value: timeoutMs)
        try socket.write(from: SourceServerInfoRequest().packet.data, to: address)
        
        var buffer = Data(capacity: 2048)
        let (bytesRead, _) = try socket.readDatagram(into: &buffer)
        socket.close()
        
        guard let response = SourceServerInfoResponse(packet: SourceServerPacket(data: buffer[..<bytesRead])) else { throw SourceServerPingError.couldNotDecodePacket }
        return response
    }
}
