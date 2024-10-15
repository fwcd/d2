import Utils

nonisolated(unsafe) private let emojiPattern = #/:[^:]:/#

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
            case .administration: "🖥️ Administration"
            case .cau: "🏫 CAU-specific utilities"
            case .coding: "💱 Encoders and decoders"
            case .d2script: "📜 D2 scripting"
            case .dictionary: "📚 Dictionaries, online search engines and more"
            case .emoji: "😎 Emoji"
            case .feed: "🗞️ Feeds"
            case .file: "📁 File IO"
            case .finance: "📈 Finance"
            case .food: "🍹 Food and drinks"
            case .forum: "📒 Forums"
            case .fun: "🍬 Fun"
            case .game: "🎲 Multiplayer games"
            case .imaging: "🌄 Image and GIF generation/editing"
            case .math: "📊 Mathematics"
            case .meta: "✨ Meta, i.e. commands related to D2 itself"
            case .misc: "🎨 Miscellaneous commands"
            case .moderation: "📣 Moderation"
            case .music: "🎸 Music, theory and chords"
            case .programming: "🎩 Programming"
            case .quote: "💬 Quotes"
            case .scripting: "🛠️ Command scripting"
            case .videogame: "🌲 Video games"
            case .web: "🌐 Web browsing"
        }
    }
    public var plainDescription: String {
        description.replacing(emojiPattern, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
