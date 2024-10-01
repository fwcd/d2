enum RookSide: CaseIterable {
    case kingside
    case queenside

    var asCastlingType: CastlingType {
        switch self {
            case .kingside: .short
            case .queenside: .long
        }
    }
}
