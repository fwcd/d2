import SwiftDiscord
import D2Permissions

public class GuitarChordCommand: StringCommand {
	public let description = "Finds a guitar chord and displays the fret pattern"
	public let sourceFile: String = #file
	public let requiredPermissionLevel = PermissionLevel.basic
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			// Parse chord and render image
			let chord = try Chord(of: input)
			let image = try GuitarChordRenderer().render(chord: chord)
			
			try output.append(image)
		} catch MusicParseError.invalidChord(let chord) {
			output.append("Invalid chord: `\(chord)`")
		} catch MusicParseError.invalidRootNote(let root) {
			output.append("Invalid root note: `\(root)`")
		} catch MusicParseError.invalidNote(let note) {
			output.append("Invalid note: `\(note)`")
		} catch MusicParseError.notInTwelveToneOctave(let note) {
			output.append("Not in the standard twelve-tone octave: `\(note)`")
		} catch MusicParseError.invalidNoteLetter(let noteLetter) {
			output.append("Invalid note letter: `\(noteLetter)`")
		} catch {
			print(error)
			output.append("An error occurred while creating chord")
		}
	}
}
