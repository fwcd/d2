import Utils

fileprivate let emojiPattern = try! Regex(from: ":[^:]:")

public enum CommandCategory: String, CaseIterable, CustomStringConvertible, Equatable {
    case administration
    case cau
    case coding
    case d2script
    case dictionary
    case emoji
    case feed
    case file
    case food
    case forum
    case fun
    case game
    case imaging
    case math
    case meta
    case misc
    case moderation
    case music
    case programming
    case quote
    case scripting
    case videogame
    case web

    public var description: String {
        switch self {
            case .administration: return ":desktop: Administration"
            case .cau: return ":school: CAU-specific utilities"
            case .coding: return ":currency_exchange: Encoders and decoders"
            case .d2script: return ":scroll: D2 scripting"
            case .dictionary: return ":books: Dictionaries, online search engines and more"
            case .emoji: return ":sunglasses: Emoji"
            case .feed: return ":newspaper2: Feeds"
            case .file: return ":file_folder: File IO"
            case .food: return ":tropical_drink: Food and drinks"
            case .forum: return ":ledger: Forums"
            case .fun: return ":candy: Fun"
            case .game: return ":game_die: Multiplayer games"
            case .imaging: return ":frame_photo: Image and GIF generation/editing"
            case .math: return ":bar_chart: Mathematics"
            case .meta: return ":sparkles: Meta, i.e. commands related to D2 itself"
            case .misc: return ":art: Miscellaneous commands"
            case .moderation: return ":loudspeaker: Moderation"
            case .music: return ":guitar: Music, theory and chords"
            case .programming: return ":tophat: Programming"
            case .quote: return ":speech_left: Quotes"
            case .scripting: return ":tools: Command scripting"
            case .videogame: return ":evergreen_tree: Video games"
            case .web: return ":globe_with_meridians: Web browsing"
        }
    }
    public var plainDescription: String {
        emojiPattern.replace(in: description, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
