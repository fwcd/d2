/**
 * Represents the transition between two game states.
 * Implementors should use a struct.
 */
public protocol GameMove {
	init(fromString str: String) throws
}
