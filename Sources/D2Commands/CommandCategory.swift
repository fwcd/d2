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
    case finance
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
            case .administration: return "🖥️ Administration"
            case .cau: return "🏫 CAU-specific utilities"
            case .coding: return "💱 Encoders and decoders"
            case .d2script: return "📜 D2 scripting"
            case .dictionary: return "📚 Dictionaries, online search engines and more"
            case .emoji: return "😎 Emoji"
            case .feed: return "🗞️ Feeds"
            case .file: return "📁 File IO"
            case .finance: return "📈 Finance"
            case .food: return "🍹 Food and drinks"
            case .forum: return "📒 Forums"
            case .fun: return "🍬 Fun"
            case .game: return "🎲 Multiplayer games"
            case .imaging: return "🌄 Image and GIF generation/editing"
            case .math: return "📊 Mathematics"
            case .meta: return "✨ Meta, i.e. commands related to D2 itself"
            case .misc: return "🎨 Miscellaneous commands"
            case .moderation: return "📣 Moderation"
            case .music: return "🎸 Music, theory and chords"
            case .programming: return "🎩 Programming"
            case .quote: return "💬 Quotes"
            case .scripting: return "🛠️ Command scripting"
            case .videogame: return "🌲 Video games"
            case .web: return "🌐 Web browsing"
        }
    }
    public var plainDescription: String {
        emojiPattern.replace(in: description, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
