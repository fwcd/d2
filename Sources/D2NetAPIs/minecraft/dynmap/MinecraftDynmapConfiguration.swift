import D2Utils

public struct MinecraftDynmapConfiguration: Codable {
    public let updaterate: Double?
    public let chatlengthlimit: Int?
    public let worlds: [World]?
    public let confighash: Int?
    public let spammessage: String?
    public let defaultmap: String?
    public let title: String?
    public let grayplayerswhenhidden: Bool?
    public let quitmessage: String?
    public let defaultzoom: Int?
    public let allowwebchat: Bool?
    public let allowchat: Bool?
    public let sidebaropened: String?
    public let loggedin: Bool?
    public let coreversion: String?
    public let joinmessage: String?
    public let showlayercontrol: String?
    public let maxcount: Int?
    public let dynmapversion: String?
    public let cyrillic: Bool?
    public let webprefix: String?
    public let showplayerfacesinmenu: Bool?
    public let defaultworld: String?
    
    public struct World: Codable {
        public let sealevel: Int?
        public let protected: Bool?
        public let maps: [Map]?
        public let extrazoomout: Int?
        public let center: Position?
        public let name: String?
        public let title: String?
        public let worldheight: Int?
        
        public struct Map: Codable {
            public let inclination: Double?
            public let nightandday: Bool?
            public let shader: String?
            public let compassview: String?
            public let scale: Int?
            public let azimuth: Double?
            public let type: String?
            public let title: String?
            public let lighting: String?
            public let bigmap: Bool?
            public let protected: Bool?
            public let mapzoomout: Int?
            public let boostzoom: Int?
            public let name: String?
            public let perspective: String?
            public let mapzoomin: Int?
            public let maptoworld: [Double]?
            public let worldtomap: [Double]?
            
            private var maptoworldMatrix: Matrix<Double> { maptoworld.map { Matrix(width: 3, height: 3, values: $0) } ?? .identity(width: 3) }
            private var worldtomapMatrix: Matrix<Double> { worldtomap.map { Matrix(width: 3, height: 3, values: $0) } ?? .identity(width: 3) }
            
            /// Converts a Minecraft location to a tile position.
            public func toTilePos(x: Double, y: Double, z: Double) -> (Double, Double) {
                let mcPos = Matrix(width: 1, height: 3, values: [x, y, z])
                let tilePos = worldtomapMatrix * mcPos
                let scale = 128.0
                return (tilePos[0, 0] / scale, (tilePos[1, 0] - scale) / scale)
            }
        }
        
        public struct Position: Codable {
            public let x: Double
            public let y: Double
            public let z: Double
        }
    }
}
