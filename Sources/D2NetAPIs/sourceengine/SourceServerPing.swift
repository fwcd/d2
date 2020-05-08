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
        let socket = try Socket.create()
        try socket.connect(to: host, port: port, timeout: timeoutMs)
        try socket.write(from: SourceServerInfoRequest().packet.data)
        
        var buffer = Data(capacity: 2048)
        let bytesRead = try socket.read(into: &buffer)
        socket.close()
        
        guard let response = SourceServerInfoResponse(packet: SourceServerPacket(data: buffer[..<bytesRead])) else { throw SourceServerPingError.couldNotDecodePacket }
        return response
    }
}
