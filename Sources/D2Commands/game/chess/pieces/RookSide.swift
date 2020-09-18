enum RookSide: CaseIterable {
    case kingside
    case queenside

    var asCastlingType: CastlingType {
        switch self {
            case .kingside: return .short
            case .queenside: return .long
        }
    }
}
