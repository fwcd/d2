import Foundation

public struct PunkAPIBeer: Codable {
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case tagline
        case firstBrewed = "first_brewed"
        case description
        case imageUrl = "image_url"
        case abv
        case ibu
        case targetFg = "target_fg"
        case targetOg = "target_og"
        case ebc
        case srm
        case ph
        case attenuationLevel = "attenuation_level"
        case volume
        case boilVolume = "boil_volume"
        case method
        case ingredients
        case foodPairing = "food_pairing"
        case brewersTips = "brewers_tips"
        case contributedBy = "contributed_by"
    }

    public let id: Int
    public let name: String
    public let tagline: String?
    public let firstBrewed: String?
    public let description: String?
    public let imageUrl: URL?
    public let abv: Double?
    public let ibu: Double?
    public let targetFg: Double?
    public let targetOg: Double?
    public let ebc: Double?
    public let srm: Double?
    public let ph: Double?
    public let attenuationLevel: Double?
    public let volume: UnitValue?
    public let boilVolume: UnitValue?
    public let method: [String: Method?]?
    public let ingredients: Ingredients?
    public let foodPairing: [String]?
    public let brewersTips: String?
    public let contributedBy: String?

    public struct UnitValue: Codable {
        public let value: Double
        public let unit: String
    }

    public struct Method: Codable {
        public let temp: UnitValue
        public let duration: Double?
    }

    public struct Ingredients: Codable {
        public let malt: [Malt]
        public let hops: [Hop]
        public let yeast: String

        public struct Malt: Codable {
            public let name: String
            public let amount: UnitValue
        }

        public struct Hop: Codable {
            public let name: String
            public let amount: UnitValue
            public let add: String
            public let attribute: String
        }
    }
}
