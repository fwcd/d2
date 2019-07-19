import D2MessageIO
import D2Permissions

public class PigLatinCommand: StringCommand {
	public let info = CommandInfo(
		category: .misc,
		shortDescription: "Encodes a string in pig latin",
		longDescription: "Encodesway away ingstray inway igpay atinlay",
		requiredPermissionLevel: .basic
	)
	private let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
	private let vowelSuffixes: [String] = ["way", "yay"]
	
	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		output.append(pigLatinOf(input))
	}
	
	private func pigLatinOf(_ str: String) -> String {
		return str.split(separator: " ").map { pigLatinWordOf(String($0).lowercased()) }.joined(separator: " ")
	}
	
	private func pigLatinWordOf(_ word: String) -> String {
		if word.isEmpty {
			return word
		} else if let vowelIndex = firstVowelIndex(in: word) {
			if vowelIndex == word.startIndex {
				return "\(word)\(vowelSuffixes.randomElement() ?? "ay")"
			} else {
				return "\(word[vowelIndex...])\(word[..<vowelIndex])ay"
			}
		} else {
			return "\(word)ay"
		}
	}
	
	private func firstVowelIndex(in str: String) -> String.Index? {
		guard !str.isEmpty else { return nil }
		var index = str.startIndex
		
		while !vowels.contains(str[index]) {
			index = str.index(after: index)
			
			if index == str.endIndex {
				return nil
			}
		}
		
		return index
	}
}
