func pieceOf(letter: Character) -> ChessPiece? {
	return [Bishop(), King(), Knight(), Pawn(), Queen(), Rook()]
		.map { ($0, $0.notationLetters.firstIndex(of: letter)) }
		.filter { $0.1 != nil }
		.min { $0.1 < $1.1 }
}
