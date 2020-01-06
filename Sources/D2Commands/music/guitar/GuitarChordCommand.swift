import SwiftDiscord
import Logging
import D2Permissions

fileprivate let log = Logger(label: "GuitarChordCommand")

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
				.embed(DiscordEmbed(
					title: "Guitar Chord \(input)",
					description: "This was the closest match for \(chord)"
				)),
				.files([DiscordFileUpload(data: try image.pngEncoded(), filename: "chord.png", mimeType: "image/png")])
			]))
		} catch ChordError.invalidChord(let chord) {
			output.append(errorText: "Invalid chord: `\(chord)`")
		} catch ChordError.invalidRootNote(let root) {
			output.append(errorText: "Invalid root note: `\(root)`")
		} catch ChordError.notOnGuitarFretboard(let chord) {
			output.append(errorText: "Could not find chord on guitar fretboard: `\(chord)`")
		} catch NoteError.invalidNote(let note) {
			output.append(errorText: "Invalid note: `\(note)`")
		} catch NoteError.notInTwelveToneOctave(let note) {
			output.append(errorText: "Not in the standard twelve-tone octave: `\(note)`")
		} catch NoteError.invalidNoteLetter(let noteLetter) {
			output.append(errorText: "Invalid note letter: `\(noteLetter)`")
		} catch {
			output.append(error, errorText: "An error occurred while creating chord")
		}
	}
}
