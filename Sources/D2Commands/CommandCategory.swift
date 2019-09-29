public enum CommandCategory: CustomStringConvertible {
    case bf
    case cau
    case d2script
    case file
    case game
    case imaging
    case math
    case misc
    case ml
    case music
    case permissions
    case reddit
    case scripting
    case stackoverflow
    case web
    case wolframalpha
    
    public var description: String {
        switch self {
            case .bf: return ":currency_exchange: BF interpreter"
            case .cau: return ":school: CAU-specific utilities"
            case .d2script: return ":scroll: D2 scripting"
            case .file: return ":file_folder: File IO"
            case .game: return ":game_die: Multiplayer games"
            case .imaging: return ":frame_photo: Image and GIF generation/editing"
            case .math: return ":bar_chart: Plotting and calculations"
            case .misc: return ":art: Miscellaneous commands"
            case .ml: return ":bulb: Machine learning"
            case .music: return ":guitar: Chord finder and music theory"
            case .permissions: return ":white_check_mark: Permission management"
            case .reddit: return ":ledger: Reddit API"
            case .scripting: return ":tools: Command scripting"
            case .stackoverflow: return ":books: Stack Overflow API"
            case .web: return ":globe_with_meridians: In-Discord web browsing"
            case .wolframalpha: return ":boom: WolframAlpha API"
        }
    }
}
