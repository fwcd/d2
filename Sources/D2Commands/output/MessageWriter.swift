import Logging
import D2MessageIO
import D2Utils

fileprivate let log = Logger(label: "D2Commands.MessageWriter")

/**
 * Writes rich values into MessageIO messages (e.g. for use with Discord).
 */
public struct MessageWriter {
    private let latexRenderer: LatexRenderer?

	public init() {
		do {
			latexRenderer = try LatexRenderer()
		} catch {
			latexRenderer = nil
			log.warning("Could not create LatexRenderer: \(error)")
		}
	}
	
	public func write(value: RichValue) -> Promise<Message, Error> {
		switch value {
			case .none:
				return Promise(Message(content: ""))
			case let .text(txt):
				if txt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					return Promise(.failure(MessageWriterError.emptyMessage))
				}
				return Promise(Message(content: txt))
			case let .mentions(users):
				return Promise(Message(content: users.map { "<@\($0.id)>" }.joined(separator: " ")))
			case let .image(img):
				return Promise(Result { try Message(fromImage: img) })
			case let .gif(gif):
				return Promise(Result { try Message(fromGif: gif) })
			case let .code(code, language: lang):
				return Promise(Message(content: """
					```\(lang ?? "")
					\(code)
					```
					"""))
			case let .embed(embed):
				return Promise(Message(embed: embed))
			case let .ndArrays(ndArrays):
				return Promise { then in
					if let renderer = latexRenderer {
						do {
							try renderer.renderImage(from: self.latexOf(ndArrays: ndArrays), onError: { then(.failure($0)) }) { img in
								then(Result { try Message(fromImage: img) })
							}
						} catch {
							then(.failure(error))
						}
					} else {
						then(.success(Message(content: ndArrays.map { "\($0)" }.joined(separator: ", "))))
					}
				}
			case let .error(error, errorText: text):
				return Promise(Message(embed: Embed(
					description: ":warning: \(error.map { "\(type(of: $0)): " } ?? "")\(text)",
					footer: Embed.Footer(text: "Check the logs for more details!")
				)))
			case let .files(files):
				return Promise(Message(files: files))
			case .attachments(_):
				// TODO: Download attachments and re-attach them as fileuploads
				return write(value: .error(nil, errorText: "Cannot write attachments yet!"))
			case let .compound(components):
				return all(promises: components.map { write(value: $0) }).map { encoded in
					Message(
						content: encoded.compactMap { $0.content.nilIfEmpty }.joined(separator: "\n"),
						embed: encoded.compactMap { $0.embed }.first,
						files: encoded.flatMap { $0.files },
						tts: false
					)
				}
		}
	}

	private func latexOf(ndArrays: [NDArray<Rational>]) -> String {
		ndArrays.map { latexOf(ndArray: $0) }.joined(separator: " ")
	}

	private func latexOf(ndArray: NDArray<Rational>) -> String {
		if let scalar = ndArray.asScalar {
			return latexOf(rational: scalar)
		} else if let matrix = ndArray.asMatrix {
			return "\\begin{pmatrix}\(matrix.asArray.map { $0.map { latexOf(rational: $0) }.joined(separator: " & ") }.joined(separator: " \\\\\\\\ "))\\end{pmatrix}"
		} else {
			return "\\begin{pmatrix}\(try! ndArray.split().map { latexOf(ndArray: $0) }.joined(separator: " & "))\\end{pmatrix}"
		}
	}

	private func latexOf(rational: Rational) -> String {
        let sign = rational.signum()
        let absReduced = abs(rational.reduced())
        let frac = absReduced.denominator == 1 ? String(absReduced.numerator) : "\\frac{\(absReduced.numerator)}{\(absReduced.denominator)}"
        return "\(sign < 0 ? "-" : "\\phantom{-}")\(frac)"
    }
}
