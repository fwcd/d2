/// Additional flags for performing game moves.
public struct GameMoveOptions: OptionSet {
    public let rawValue: Int

    /// Commit the move, i.e. perform some non-essential actions like saving move history.
    public static let commit = GameMoveOptions(rawValue: 1 << 0)
    /// Skip the validity check. This can potentially save expensive computations of the
    /// possible moves, should however only be used if e.g. already using a possible move.
    /// Only used with childState.
    public static let skipCheck = GameMoveOptions(rawValue: 1 << 1)
    /// Skip preprocessing of moves, e.g. disambiguations.
    public static let skipPreprocessing = GameMoveOptions(rawValue: 1 << 2)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
