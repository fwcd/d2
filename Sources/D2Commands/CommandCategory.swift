public enum CommandCategory: String, CaseIterable, CustomStringConvertible, Equatable {
    case bf
    case cau
    case coding
    case d2script
    case dictionary
    case essential
    case file
    case fun
    case game
    case gitlab
    case gmod
    case haskell
    case imaging
    case math
    case minecraft
    case misc
    case ml
    case music
    case permissions
    case prolog
    case reddit
    case scripting
    case stackoverflow
    case web
    case wolframalpha
    case xkcd
    
    public var description: String {
        switch self {
            case .bf: return ":brain: BF interpreter"
            case .cau: return ":school: CAU-specific utilities"
            case .coding: return ":currency_exchange: Encoders and decoders"
            case .d2script: return ":scroll: D2 scripting"
            case .dictionary: return ":closed_book: Dictionaries"
            case .essential: return ":sparkles: Fundamental commands (such as `help`)"
            case .file: return ":file_folder: File IO"
            case .fun: return ":candy: Fun"
            case .game: return ":game_die: Multiplayer games"
            case .gitlab: return ":fox: GitLab"
            case .gmod: return ":regional_indicator_g: Garry's Mod"
            case .haskell: return ":umbrella2: Haskell"
            case .imaging: return ":frame_photo: Image and GIF generation/editing"
            case .math: return ":bar_chart: Mathematics"
            case .minecraft: return ":evergreen_tree: Minecraft"
            case .misc: return ":art: Miscellaneous commands"
            case .ml: return ":bulb: Machine learning"
            case .music: return ":guitar: Chord finder and music theory"
            case .permissions: return ":white_check_mark: Permission management"
            case .prolog: return ":owl: Prolog"
            case .reddit: return ":ledger: Reddit API"
            case .scripting: return ":tools: Command scripting"
            case .stackoverflow: return ":books: Stack Overflow API"
            case .web: return ":globe_with_meridians: In-Discord web browsing"
            case .wolframalpha: return ":boom: WolframAlpha API"
            case .xkcd: return ":pencil2: xkcd"
        }
    }
}
