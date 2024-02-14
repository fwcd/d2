import Foundation
import Socket

public struct SourceServerQuery<R, S> where R: ToSourceServerPacket, S: FromSourceServerPacket {
    private let request: R
    private let host: String
    private let port: Int32
    private let timeoutMs: UInt

    public init(request: R, host: String, port: Int32, timeoutMs: UInt = 0) {
        self.request = request
        self.host = host
        self.port = port
        self.timeoutMs = timeoutMs
    }

    public func perform() throws -> S {
        guard let address = Socket.createAddress(for: host, on: port) else { throw SourceServerQueryError.invalidAddress(host, port) }
        let socket = try Socket.create(type: .datagram, proto: .udp)

        try socket.setReadTimeout(value: timeoutMs)
        try socket.write(from: request.packet.data, to: address)

        var buffer = Data(capacity: 2048)
        let (bytesRead, _) = try socket.readDatagram(into: &buffer)
        socket.close()

        guard bytesRead > 0 else { throw SourceServerQueryError.noResponse }
        var packet = SourceServerPacket(data: buffer[..<bytesRead])
        guard let header = packet.readLong(), header == 0xFFFFFFFF else { throw SourceServerQueryError.invalidHeader }
        guard let response = S.init(packet: packet) else { throw SourceServerQueryError.couldNotDecodePacket }
        return response
    }
}
