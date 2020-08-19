public enum CommandCategory: String, CaseIterable, CustomStringConvertible, Equatable {
    case administration
    case bf
    case cau
    case coding
    case comic
    case d2script
    case dictionary
    case file
    case food
    case forum
    case fun
    case game
    case git
    case gmod
    case haskell
    case imaging
    case math
    case meta
    case minecraft
    case misc
    case ml
    case moderation
    case music
    case prolog
    case scripting
    case web

    public var description: String {
        switch self {
            case .administration: return ":desktop: Administration"
            case .bf: return ":brain: BF interpreter"
            case .cau: return ":school: CAU-specific utilities"
            case .coding: return ":currency_exchange: Encoders and decoders"
            case .comic: return ":pencil2: Comics"
            case .d2script: return ":scroll: D2 scripting"
            case .dictionary: return ":books: Dictionaries, online search engines and more"
            case .file: return ":file_folder: File IO"
            case .food: return ":tropical_drink: Food and drinks"
            case .forum: return ":ledger: Forums"
            case .fun: return ":candy: Fun"
            case .game: return ":game_die: Multiplayer games"
            case .git: return ":fox: Git"
            case .gmod: return ":regional_indicator_g: Garry's Mod"
            case .haskell: return ":umbrella2: Haskell"
            case .imaging: return ":frame_photo: Image and GIF generation/editing"
            case .math: return ":bar_chart: Mathematics"
            case .meta: return ":sparkles: Meta, i.e. commands related to D2 itself"
            case .minecraft: return ":evergreen_tree: Minecraft"
            case .misc: return ":art: Miscellaneous commands"
            case .ml: return ":bulb: Machine learning"
            case .moderation: return ":loudspeaker: Moderation"
            case .music: return ":guitar: Music, theory and chords"
            case .prolog: return ":owl: Prolog"
            case .scripting: return ":tools: Command scripting"
            case .web: return ":globe_with_meridians: Web browsing"
        }
    }
}
