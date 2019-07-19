import D2MessageIO
import D2Permissions

// TODO: Use Arg API

public class GuitarChordCommand: StringCommand {
	public let info = CommandInfo(
		category: .music,
		shortDescription: "Finds a guitar chord",
		longDescription: "Finds a guitar chord and displays the fret pattern",
		requiredPermissionLevel: .basic
	)
	public let outputValueType: RichValueType = .image
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		do {
			// Parse chord and render image
			let chord = try Chord(of: input)
			let image = try GuitarChordRenderer().render(chord: chord)
			
			output.append(.compound([
				.embed(Embed(
					title: "Guitar Chord \(input)",
					description: "This was the closest match for \(chord)"
				)),
				.files([Message.FileUpload(data: try image.pngEncoded(), filename: "chord.png", mimeType: "image/png")])
			]))
		} catch ChordError.invalidChord(let chord) {
			output.append("Invalid chord: `\(chord)`")
		} catch ChordError.invalidRootNote(let root) {
			output.append("Invalid root note: `\(root)`")
		} catch ChordError.notOnGuitarFretboard(let chord) {
			output.append("Could not find chord on guitar fretboard: `\(chord)`")
		} catch NoteError.invalidNote(let note) {
			output.append("Invalid note: `\(note)`")
		} catch NoteError.notInTwelveToneOctave(let note) {
			output.append("Not in the standard twelve-tone octave: `\(note)`")
		} catch NoteError.invalidNoteLetter(let noteLetter) {
			output.append("Invalid note letter: `\(noteLetter)`")
		} catch {
			print(error)
			output.append("An error occurred while creating chord")
		}
	}
}
