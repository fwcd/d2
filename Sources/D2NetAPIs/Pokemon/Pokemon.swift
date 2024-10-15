import Foundation

public struct Pokemon: Sendable, Codable {
    public enum CodingKeys: String, CodingKey {
        case abilities
        case baseExperience = "base_experience"
        case forms
        case gameIndices = "game_indices"
        case height
        case heldItems = "held_items"
        case id
        case isDefault = "is_default"
        case locationAreaEncounters = "location_area_encounters"
        case moves
        case name
        case order
        case species
        case sprites
        case stats
        case types
        case weight
    }

    public let abilities: [AbilitySlot]?
    public let baseExperience: Int?
    public let forms: [NamedPokemonResource]?
    public let gameIndices: [GameIndex]?
    public let height: Int?
    public let heldItems: [HeldItem]?
    public let id: Int
    public let isDefault: Bool?
    public let locationAreaEncounters: URL?
    public let moves: [Move]?
    public let name: String
    public let order: Int?
    public let species: NamedPokemonResource?
    public let sprites: Sprites?
    public let stats: [Stat]?
    public let types: [TypeSlot]?
    public let weight: Int?

    public struct AbilitySlot: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case ability
            case isHidden = "is_hidden"
            case slot
        }

        public let ability: NamedPokemonResource
        public let isHidden: Bool
        public let slot: Int
    }

    public struct GameIndex: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case gameIndex = "game_index"
            case version
        }

        public let gameIndex: Int
        public let version: NamedPokemonResource?
    }

    public struct HeldItem: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case item
            case versionDetails = "version_details"
        }

        public let item: NamedPokemonResource
        public let versionDetails: [VersionDetail]?

        public struct VersionDetail: Sendable, Codable {
            public let rarity: Int
            public let version: NamedPokemonResource
        }
    }

    public struct Move: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case move
            case versionGroupDetails = "version_group_details"
        }

        public let move: NamedPokemonResource
        public let versionGroupDetails: [VersionGroupDetail]?

        public struct VersionGroupDetail: Sendable, Codable {
            public enum CodingKeys: String, CodingKey {
                case levelLearnedAt = "level_learned_at"
                case moveLearnMethod = "move_learn_method"
                case versionGroup = "version_group"
            }

            public let levelLearnedAt: Int
            public let moveLearnMethod: NamedPokemonResource
            public let versionGroup: NamedPokemonResource
        }
    }

    public struct Sprites: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case backDefault = "back_default"
            case backFemale = "back_female"
            case backShiny = "back_shiny"
            case backShinyFemale = "back_shiny_female"
            case frontDefault = "front_default"
            case frontFemale = "front_female"
            case frontShiny = "front_shiny"
            case frontShinyFemale = "front_shiny_female"
        }

        public let backDefault: URL?
        public let backFemale: URL?
        public let backShiny: URL?
        public let backShinyFemale: URL?
        public let frontDefault: URL?
        public let frontFemale: URL?
        public let frontShiny: URL?
        public let frontShinyFemale: URL?

        public var url: URL? {
            [frontDefault, frontFemale, frontShiny, frontShinyFemale, backDefault, backFemale, backShiny, backShinyFemale]
                .compactMap { $0 }
                .first
        }
    }

    public struct Stat: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case baseStat = "base_stat"
            case effort
            case stat
        }

        public let baseStat: Int
        public let effort: Int
        public let stat: NamedPokemonResource
    }

    public struct TypeSlot: Sendable, Codable {
        public let slot: Int
        public let type: NamedPokemonResource
    }
}
