import CairoGraphics

public struct ChessTheme: Sendable {
    public static let defaultTheme: ChessTheme = ChessTheme(
        lightColor: Color(rgb: 0xfad8aa),
        darkColor: Color(rgb: 0xaf4d11)
    )

    public let lightColor: Color
    public let darkColor: Color
}
