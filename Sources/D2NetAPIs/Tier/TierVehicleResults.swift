import Utils
import Geodesy

public struct TierVehicleResults: Codable {
    public let data: [Vehicle]

    public struct Vehicle: Codable {
        public let type: String
        public let id: String
        public let attributes: Attributes

        public struct Attributes: Codable {
            public let state: String
            public let lastLocationUpdate: String?
            public let lastStateChange: String?
            public let batteryLevel: Int?
            public let lat: Double
            public let lng: Double
            public let maxSpeed: Int?
            public let zoneId: String?
            public let code: Int?
            public let iotVendor: String?
            public let licensePlate: String?
            public let isRentable: Bool?
            public let vehicleType: String?
            public let hasHelmetBox: Bool?
            public let hasHelmet: Bool?

            public var coords: Coordinates { Coordinates(latitude: lat, longitude: lng) }
        }
    }
}
