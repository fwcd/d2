import Logging
import D2MessageIO
import D2Permissions
import Utils

fileprivate let log = Logger(label: "D2Commands.FretboardChordCommand")
fileprivate let argPattern = #/(?<chord>\w+)(?:\s+(?<instrument>\w+))?/#

public class FretboardChordCommand: StringCommand {
    public let info = CommandInfo(
        category: .music,
        shortDescription: "Finds a guitar/ukulele chord",
        longDescription: "Finds a guitar/ukulele chord and displays the fret pattern",
        helpText: "Syntax: [chord] [instrument]?",
        requiredPermissionLevel: .basic
    )
    public let outputValueType: RichValueType = .image
    private let fretboards: [String: Fretboard] = [
        "guitar": Fretboard(tuning: standardGuitarTuning),
        "ukulele": Fretboard(tuning: standardUkuleleTuning),
        "bass": Fretboard(tuning: standardBassTuning)
    ]

    public init() {}

    public func invoke(with input: String, output: any CommandOutput, context: CommandContext) async {
        do {
            guard let parsedArgs = try? argPattern.firstMatch(in: input) else {
                await output.append(errorText: info.helpText!)
                return
            }
            let rawChord = String(parsedArgs.chord)
            let rawInstrument = String(parsedArgs.instrument?.lowercased() ?? "guitar")

            // Parse chord and render image
            let chord = try CommonChord(of: rawChord)
            guard let fretboard = fretboards[rawInstrument] else {
                await output.append(errorText: "Unknown instrument `\(rawInstrument)`, try one of these: `\(fretboards.keys.joined(separator: ", "))`")
                return
            }

            let image = try FretboardChordRenderer(fretboard: fretboard).render(chord: chord)

            await output.append(.compound([
                .embed(Embed(
                    title: "\(rawInstrument.withFirstUppercased) Chord \(rawChord)",
                    description: "This was the closest match for \(chord)"
                )),
                .files([Message.FileUpload(data: try image.pngEncoded(), filename: "chord.png", mimeType: "image/png")])
            ]))
        } catch ChordError.invalidChord(let chord) {
            await output.append(errorText: "Invalid chord: `\(chord)`")
        } catch ChordError.invalidRootNote(let root) {
            await output.append(errorText: "Invalid root note: `\(root)`")
        } catch ChordError.notOnFretboard(let chord) {
            await output.append(errorText: "Could not find chord on guitar fretboard: `\(chord)`")
        } catch NoteError.invalidNote(let note) {
            await output.append(errorText: "Invalid note: `\(note)`")
        } catch NoteError.notInTwelveToneOctave(let note) {
            await output.append(errorText: "Not in the standard twelve-tone octave: `\(note)`")
        } catch NoteError.invalidNoteLetter(let noteLetter) {
            await output.append(errorText: "Invalid note letter: `\(noteLetter)`")
        } catch {
            await output.append(error, errorText: "An error occurred while creating chord")
        }
    }
}
